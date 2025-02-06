# Modified checkpoint_aggregator.py
from ConfigParser import ConfigParser
import gzip
import sys, re, os

class myCP(ConfigParser):
    def __init__(self):
        ConfigParser.__init__(self)

    def optionxform(self, optionstr):
        return optionstr

def aggregate(output_dir, cpts, no_compress, memory_size):
    merged_config = None
    page_ptr = 0

    output_path = output_dir
    if not os.path.isdir(output_path):
        os.system("mkdir -p " + output_path)

    agg_mem_file = open(output_path + "/system.physmem.store0.pmem", "wb+")
    agg_config_file = open(output_path + "/m5.cpt", "wb+")

    if not no_compress:
        merged_mem = gzip.GzipFile(fileobj=agg_mem_file, mode="wb")

    max_curtick = 0
    num_digits = len(str(7))  # Modified: Fixed to 8 CPUs (0-7)

    for (i, arg) in enumerate(cpts):
        print arg
        merged_config = myCP()
        config = myCP()
        config.readfp(open(cpts[i] + "/m5.cpt"))

        for sec in config.sections():
            if re.compile("cpu").search(sec):
                # Modified: Extract the local CPU ID and map to sequential
                local_cpu_match = re.search(r"cpu(\d+)", sec)
                if local_cpu_match:
                    local_cpu_id = int(local_cpu_match.group(1))
                    newsec = "cpu" + str(i * 2 + local_cpu_id).zfill(num_digits)
                merged_config.add_section(newsec)

                items = config.items(sec)
                for item in items:
                    if item[0] == "paddr":
                        merged_config.set(newsec, item[0], int(item[1]) + (page_ptr << 12))
                        continue
                    merged_config.set(newsec, item[0], item[1])

                if re.compile("workload.FdMap256$").search(sec):
                    merged_config.set(newsec, "M5_pid", i)

            elif sec == "system":
                pass
            elif sec == "Globals":
                tick = config.getint(sec, "curTick")
                if tick > max_curtick:
                    max_curtick = tick
            else:
                if i == len(cpts)-1:
                    merged_config.add_section(sec)
                    for item in config.items(sec):
                        merged_config.set(sec, item[0], item[1])

        if i != len(cpts)-1:
            merged_config.write(agg_config_file)

        pages = int(config.get("system", "pagePtr"))
        page_ptr = page_ptr + pages
        print "pages to be read from checkpoint {}: {}".format(i, pages)

        f = open(cpts[i] + "/system.physmem.store0.pmem", "rb")
        gf = gzip.GzipFile(fileobj=f, mode="rb")

        x = 0
        while x < pages:
            bytesRead = gf.read(1 << 12)
            if not no_compress:
                merged_mem.write(bytesRead)
            else:
                agg_mem_file.write(bytesRead)
            x += 1

        gf.close()
        f.close()

    merged_config.add_section("system")
    merged_config.set("system", "pagePtr", page_ptr)
    merged_config.set("system", "nextPID", 8)  # Modified: Fixed for 8 CPUs

    file_size = page_ptr * 4 * 1024
    dummy_data = "".zfill(4096)
    while file_size < memory_size:
        if not no_compress:
            merged_mem.write(dummy_data)
        else:
            agg_mem_file.write(dummy_data)
        file_size += 4 * 1024
        page_ptr += 1

    print "WARNING: "
    print "Make sure the simulation using this checkpoint has at least ",
    print page_ptr, "x 4K of memory"
    merged_config.set("system.physmem.store0", "range_size", page_ptr * 4 * 1024)

    merged_config.add_section("Globals")
    merged_config.set("Globals", "curTick", max_curtick)

    merged_config.write(agg_config_file)

    if not no_compress:
        merged_mem.close()
        agg_mem_file.close()
    else:
        agg_mem_file.close()

if __name__ == "__main__":
    from argparse import ArgumentParser
    parser = ArgumentParser("usage: %prog [options] <directory names which "\
                            "hold the checkpoints to be combined>")
    parser.add_argument("-o", "--output-dir", action="store",
                        help="Output directory")
    parser.add_argument("-c", "--no-compress", action="store_true")
    parser.add_argument("--cpts", nargs='+')
    parser.add_argument("--memory-size", action="store", type=int)

    options = parser.parse_args()
    print options.cpts, len(options.cpts)
    if len(options.cpts) <= 2:
        parser.error("You must specify at least three checkpoint files that "\
                     "need to be combined.")

    aggregate(options.output_dir, options.cpts, options.no_compress,
              options.memory_size)
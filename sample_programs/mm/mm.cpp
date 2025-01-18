#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <cassert>
#include "zsim_hooks.h"

#define MATRIX_SIZE 1024  // Adjust for larger workloads

void initialize_matrix(std::vector<std::vector<double>>& matrix) {
    int size = matrix.size();
    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j) {
            matrix[i][j] = rand() % 100;
        }
    }
}

void multiply_matrices(const std::vector<std::vector<double>>& a,
                       const std::vector<std::vector<double>>& b,
                       std::vector<std::vector<double>>& c) {
    int size = a.size();

    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j) {
            c[i][j] = 0;

            // Plugin code: Start to compute
            std::cout << "here, start to compute " << (i * size + j) << std::endl;

            #ifdef DUMP_CHECKPOINT
            __asm__ __volatile__ (".word 0x040F; .word 0x0043;" : : "D" (0), "S" (0) :);
            #endif
            zsim_roi_begin();

            #ifndef GET_SHORT_DAG
            zsim_heartbeat();  // This starts to get DAG
            #endif

            // Main computation
            for (int k = 0; k < size; ++k) {
                c[i][j] += a[i][k] * b[k][j];
            }


        }
    }

#ifndef GET_SHORT_DAG
    zsim_heartbeat();  // This ends to get DAG
#endif
}

int main() {
    std::cout << "Matrix Multiplication Application with DAG Monitoring" << std::endl;
    srand(static_cast<unsigned>(time(nullptr)));

    int size = MATRIX_SIZE;

    // Initialize matrices using vectors
    std::vector<std::vector<double>> matrixA(size, std::vector<double>(size));
    std::vector<std::vector<double>> matrixB(size, std::vector<double>(size));
    std::vector<std::vector<double>> matrixC(size, std::vector<double>(size));

    // Fill matrices with random values
    initialize_matrix(matrixA);
    initialize_matrix(matrixB);

    // Perform matrix multiplication
    multiply_matrices(matrixA, matrixB, matrixC);

    // End DAG monitoring
    zsim_roi_end();

    std::cout << "Matrix multiplication completed." << std::endl;
    return 0;
}

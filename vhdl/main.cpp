#include <iostream>
#include <cmath>
#include <vector>
#include <iomanip>
#include <bitset>

const int ITERS = 16;

// Funzione per calcolare la tabella dei valori arctan(2^-i) in formato a virgola fissa
std::vector<int> compute_theta_table(int iterations) {
    std::vector<int> theta_table;
    for (int i = 0; i < iterations; ++i) {
        double theta = atan2(1.0, pow(2, i));
        theta_table.push_back(static_cast<int>(theta * (1 << 16))); // Scala con 2^16
    }
    return theta_table;
}

// Funzione per calcolare il fattore K (come costante)
int compute_K_fixed(int n) {
    double k = 1.0;
    for (int i = 0; i < n; ++i) {
        k *= 1.0 / sqrt(1.0 + pow(2, -2 * i));
    }
    return static_cast<int>(k * (1 << 16)); // Scala con 2^16
}

// Funzione per simulare una moltiplicazione senza operatore *
int simulate_multiplication(int a, int b) {
    int result = 0;
    while (b != 0) {
        if (b & 1) { // Se il bit meno significativo di b è 1, aggiungi a al risultato
            result += a;
        }
        a <<= 1; // Sposta a di un bit a sinistra (equivalente a moltiplicare per 2)
        b >>= 1; // Sposta b di un bit a destra (equivalente a dividere per 2)
    }
    return result;
}

// Funzione CORDIC che opera su interi a virgola fissa
void CORDIC(int x, int y, int n)
{
    std::vector<int> theta_table = compute_theta_table(n);
    int K_n = compute_K_fixed(n); // Fattore K in formato a virgola fissa
    int theta = 0;

    for (int i = 0; i < n; ++i) {
        int di = (y >= 0) ? -1 : 1;

        // Operazioni aritmetiche su interi a virgola fissa
        int x_new = x - ((y * di) >> i);
        int y_new = y + ((x * di) >> i);
        int theta_new = theta - di * theta_table[i];

        x = x_new;
        y = y_new;
        theta = theta_new;

        // Output intermedio
        std::cout << "x: " << static_cast<double>(x) / (1 << 16)
                  << ", y: " << static_cast<double>(y) / (1 << 16)
                  << ", z: " << static_cast<double>(theta) / (1 << 16) << std::endl;
    }

    std::cout << "At the end we have rho = " << static_cast<double>(x) / (1 << 16) * K_n / (1 << 16)<< std::endl;

    int new_x = (x << 2) + (x << 4) + (x << 5) + (x << 6) + (x << 8) + (x << 9) + (x << 11) + (x << 12) + (x << 15);

    std::cout << "x = " << x << std::endl;
    std::cout << "new_x = " << new_x << std::endl;

    std::cout << "1/k =  " << static_cast<double>(K_n) / (1 << 16) << std::endl;
    std::cout << "1/k =  " << (K_n) << std::endl;
    std::cout << "1/k * x =  " << static_cast<double>(K_n) * static_cast<double>(x) / (1 << 16) / (1 << 16) << std::endl;
    std::cout << "At the end without multiplication we have rho = " << static_cast<double>(new_x) / (1 << 16) << std::endl;

    // Calcolo finale
    //int fixed_multiplier = 0b00000000000000001001101101110101; // 98741 in decimale
    // int rho = simulate_multiplication(x, fixed_multiplier) >> 16; // Simulazione della moltiplicazione

    //std::cout << "At the end we have rho = " << static_cast<double>(rho) / (1 << 16) << " and theta = " << static_cast<double>(theta) / (1 << 16) << std::endl;
}

// Funzione principale
int main() {
    int x = 0; // 1.0 in formato a virgola fissa
    int y = 0;       // 0.0 in formato a virgola fissa
    CORDIC(x, y, ITERS);
    return 0;
}


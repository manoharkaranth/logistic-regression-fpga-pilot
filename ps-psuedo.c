/* Note: Due to minimal availability of the hardware resources during the execution of this project, 
only the pseudo code is designed for PS as mentioned by the Professor */

#include <stdio.h>
#include <stdint.h>

/* Defining AXI memory-mapped register addresses */
/* Adresses for weight0, weight1, bias, feature0, feature1 */
#define AXI_WEIGHT0_ADDR   0x40000000  
#define AXI_WEIGHT1_ADDR   0x40000004  
#define AXI_BIAS_ADDR      0x40000008  
#define AXI_INPUT0_ADDR    0x4000000C  
#define AXI_INPUT1_ADDR    0x40000010  
#define AXI_RESULT_ADDR    0x40000014  
#define AXI_READ_ENABLE    0x40000018  



/* Simulated model parameters (weights and bias for two features) */
const int32_t weights[2] = {5, -3};  
const int32_t bias = 1;              
/* Fixed bias, weight and sensor data */

/* Simulated sensor data */
const int32_t feature_data[2] = {12, 8};  

/* AXI memory-mapped registers write here */
void write_axi(int32_t *address, int32_t value) {
    *address = value;
}

/* Reading from AXI memory-mapped registers module */
int32_t read_axi(int32_t *address) {
    return *address;
}


int main() {
    /* Load model parameters into FPGA's BRAM */
    write_axi((int32_t *)AXI_WEIGHT0_ADDR, weights[0]);
    write_axi((int32_t *)AXI_WEIGHT1_ADDR, weights[1]);
    write_axi((int32_t *)AXI_BIAS_ADDR, bias);

    /* Send features to FPGA */
    write_axi((int32_t *)AXI_INPUT0_ADDR, feature_data[0]);
    write_axi((int32_t *)AXI_INPUT1_ADDR, feature_data[1]);

    /* Trigger computation by setting read_enable */
    write_axi((int32_t *)AXI_READ_ENABLE, 1);  
    write_axi((int32_t *)AXI_READ_ENABLE, 0);  
    /* Assert and  Deassert after one cycle */

    /* Reading result from FPGA */
    int32_t result = read_axi((int32_t *)AXI_RESULT_ADDR);
    printf("Inference Result: %d\n", result);

    /* Classification results (threshold at 0.5 for binary classification) 
    (This is based on the result obtained in PL so 1 is the threshold) */
    if (result >= 1) {  
        printf("Class: 1 (Positive)\n");
    } else {
        printf("Class: 0 (Negative)\n");
    }

    return 0;
}

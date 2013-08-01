target = "xilinx"
action = "synthesis"

syn_device = "xc6vlx240t"
syn_grade = "-1"
syn_package = "ff1156"

syn_top = "virtex6_fmc_adc_250m_4ch_adc_test"
syn_project = "virtex6_fmc_adc_250m_4ch_adc_test.xise"

modules = { "local" : [ "../../top/ml605/fmc250m_adc_test" ] };


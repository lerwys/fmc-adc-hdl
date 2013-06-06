target = "xilinx"
action = "synthesis"

syn_device = "xc6vlx240t"
syn_grade = "-1"
syn_package = "ff1156"

syn_top = "virtex6_fmc_adc_250m_4ch"
syn_project = "virtex6_fmc_adc_250m_4ch.xise"

modules = { "local" : [ "../../top/ml605/fmc250m" ] };


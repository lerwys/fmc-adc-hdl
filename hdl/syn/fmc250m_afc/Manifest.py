target = "xilinx"
action = "synthesis"

# Artix7 200T
syn_device = "xc7a200t"
syn_grade = "-2"
syn_package = "ffg1156"

syn_top = "artix7_amc_fmc_adc_250m_4ch"
syn_project = "artix7_amc_fmc_adc_250m_4ch.xise"

modules = { "local" : [ "../../top/afc/fmc250m" ] };


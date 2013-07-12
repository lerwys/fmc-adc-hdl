def __dirs():
	dirs = ["modules/addr_decoder",
		"modules/dcm_shift",
		"modules/fmc_adc_130m_4ch",
		"modules/fmc_adc_250m_4ch",
		"modules/rs232_syscon",
		"modules/wb_spi_bidir"
	      ]
	if (target == "xilinx" and syn_device[0:4].upper()=="XC6V"):
		dirs.extend(["platform/virtex6/ip_cores"]);
	elif (target == "xilinx" and syn_device[0:4].upper()=="XC7K"):
		dirs.extend(["platform/kintex7/ip_cores"]);
	elif (target == "xilinx" and syn_device[0:4].upper()=="XC7A"):
		dirs.extend(["platform/artix7/ip_cores"]);
	#else: #add paltform here and generate the corresponding ip cores
	return dirs

modules = {
    "local" : __dirs()
           }

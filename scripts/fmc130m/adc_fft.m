function adc_fft( sampling_freq, adc_file_name, filter_type = "hanning", several_fft = 1, window_size = 1)
# Author: Andrzej Wojenski
# Calculates FFT of ADC data
# adc_file_name - contains samples from ADC chip
# sampling_freq - sampling frequency of ADC chip (125Mhz)
# for Blackman-Harris window function octave-signal package is needed

# tests on ADC AD9255BCPZ-125
# are performed under -1 dBFS
# specify maximum input voltage

######################
# DEFINE
######################

# Define amplitude of maximum input signal
# for FMC ADC 125M 1CH DAC 600M 1CH
# max input voltage is 0.8V (amp), 1.6Vpp

# Define V_REF (Vpp) - need to change it since maximum level of voltage input for FMC card is about 1.6Vpp
v_ref_Vpp = 2
# Define number_bits (without sign)
#max_bit_value_adc = 8191 # 0x1FFF (max value, 13-bit without sign)
#max_bit_value_adc = 9829 # 1.2 of FULL_SCALE
max_bit_value_adc = 1 # Test

# signal that was used for measurement was
# 
disp("Input signal that should be used for measurement ( -1 dBFS) is:")
v_1dBFs_amp = (v_ref_Vpp / 2) * 0.8
v_1dBFs_Vpp = 2 * v_1dBFs_amp

######################
# DEFINE END
######################

# open file
fid = fopen(adc_file_name, "r");

y_final = 0;
n_items_final = 0;

[data, n_items] = fscanf(fid, "%d\n");

# test signal
#Fs = 125000000;
#t = 0:1/Fs:0.0001;
#data = sin(2*pi*t*10000000) + sin(2*pi*t*30000000);
#data = sin(2*pi*t*10000000);
#data = data';
#n_items = length(data)
# test signal end

data_vector = linspace(0, 1, n_items);
figure(3)
plot(data_vector, data);

# scale input values according to v_max (amplitude) for tests only!
#data = data ./ max_bit_value_adc;

# add window
if (strcmp(filter_type, "hanning"))
	win = hanning(n_items);
	data = data .* win;	
elseif (strcmp(filter_type, "blackman_harris")) # need octave-signal library
	win = blackmanharris(n_items);
	data = data .* win';
endif

# scale values
max_val = max(data)
data = data ./ max_val;

	if (several_fft == 1 && window_size == 1)
		# calculate fft
		[log_f, log_e] = log2(n_items);

		if (log_f == 0.5000 )			
			nfft = n_items; 		# using already power of 2
		else			
			nfft = 2^(nextpow2(n_items));
		endif
		
		fft_val = fft(data, nfft);

		num_points = ceil((nfft+1)/2);

		fft_val = fft_val(1:num_points);
		m_fft_val = abs(fft_val);

		m_fft_val = m_fft_val / n_items;

		m_fft_val = m_fft_val .^ 2;

		if (rem(nfft,2))
			m_fft_val(2:end) = m_fft_val(2:end)*2;
		else
			m_fft_val(2:end-1) = m_fft_val(2:end-1)*2;
		endif
	
		f = (0:num_points-1) * sampling_freq / nfft;

		# scale
		max_val = max(m_fft_val);
		m_fft_val = m_fft_val ./ max_val;

		# values into dB
		m_fft_val = 20*log10(m_fft_val); # since this is amplitude

		#y_final += y;
		y_final = m_fft_val;				

		figure(1)
		x = linspace(0, 1, n_items);
		plot(x, data);
	else
		for j=1:several_fft

			data_window = data( ((j-1)*window_size+1) : (j*window_size+1) );
			# calculate fft
			nfft = 2^(nextpow2(window_size));
			y = abs(fft(data_window, nfft));
			y = y(1:window_size/2);

			y_final = y_final .+ y;
			
			n_items = window_size;	
			
		endfor

		f = sampling_freq * (0:n_items/2-1)/n_items;
	
	endif

fclose(fid);

y_final = y_final ./ several_fft;

figure(2)
#semilogy(f, y_final);
plot(f, y_final);
ylabel("Amplitude [dBFS]");
xlabel("Frequency [Hz]");

endfunction

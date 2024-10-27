import scipy
import matplotlib.pyplot as plot
import numpy as np

fs = 500
f = 5
t = np.linspace(0, 1, num=fs, endpoint = True)
bandpass_hz = 100

signal = scipy.signal.square(2*np.pi * f * t)

# Plot the square wave
plot.figure()
plot.plot(t, signal)

# Give x,y,title axis label 
plot.xlabel('Time')
plot.ylabel('Amplitude')
plot.title('Square Wave - A=1, T=.2')
 
plot.axhline(y = 0, color = 'k')
 
# Display 
plot.show()

# Show FFT
yf_orig = scipy.fft.fft(signal)
yf_orig[bandpass_hz+1 : -bandpass_hz] = 0
yf = scipy.fft.fftshift(yf_orig)
xf = scipy.fft.fftfreq(fs, 1/500)
xf = scipy.fft.fftshift(xf)

plot.figure()
plot.plot(xf, 1.0/f * np.abs(yf))
plot.grid()
 
plot.xlabel('Frequency')
plot.ylabel('Amplitude')
plot.title('Square Wave FFT - A=1, T=.2')

plot.show()

signal_reconstructed = scipy.fft.ifft(yf_orig)

plot.figure()
plot.plot(t, signal_reconstructed)
plot.grid()
 
plot.xlabel('Frequency')
plot.ylabel('Time')
plot.title('Square Wave iFFT - A=1, T=.2')

plot.show()

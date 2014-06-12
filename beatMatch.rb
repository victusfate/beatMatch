require "ruby-audio"
require "narray"
require "fftw3"
require 'json'

# calculate individual element of FFT matrix:  (e ^ (2 pi i k/n))
# fft_matrix[i][j] = omega(i*j, n)
#
def omega(k, n)
    Math::E ** Complex(0, 2 * Math::PI * k / n)
end

def fft(vec)
    # puts "vect #{vec}"
    return vec if vec.size <= 1

    even = Array.new(vec.size / 2) { |i| vec[2 * i] }
    odd  = Array.new(vec.size / 2) { |i| vec[2 * i + 1] }
    
    # puts "even #{even}"
    # puts "odd #{odd}"

    fft_even = fft(even)
    fft_odd  = fft(odd)

    fft_even.concat(fft_even)
    fft_odd.concat(fft_odd)

    # puts "even #{fft_even}"
    # puts "odd #{fft_odd}"


    Array.new(vec.size) {|i| fft_even[i] + fft_odd[i] * omega(-i, vec.size)}
end

fname = ARGV[0]
window_size = 512
wave = Array.new
fftResults = Array.new []

nsamples = 0

itime = 0.023220

begin
    begin
        buf = RubyAudio::Buffer.float(window_size)
        RubyAudio::Sound.open(fname) do |snd|
            puts snd.inspect
            while snd.read(buf) != 0
                # dump these every 30hz
                # if time 30hz compute fft and dump
                wave.concat(buf.to_a)
                signal = NArray.to_na(buf.to_a)
                fft_slice = FFTW3.fft(signal).to_a[0, window_size/2]

                # signal = buf.to_a
                # fft_slice = fft(signal).to_a[0, window_size/2]

                # puts "slice size #{fft_slice.size}"
                mag = []
                fft_slice.each { |x| 
                    # puts "x #{x}"
                    # puts "real #{x.real}"
                    # puts "imag #{x.imag}"
                    mag << x.magnitude; 
                }
                fftResults << mag
                nsamples += 1
                break if nsamples == 100
            end
        end

    rescue => err
        puts "error reading audio file: ", err
    end


    # frequency bins
    # Sampling rate : 44.1 KHz
    # Bit depth     : 16 bits
    # nyquist frequency 22050 Hz
    # 512 samples or half window size ~43.1 hz per bin
    
    freq = 22050/256;
    ifile = 0

    fileName = 'spectrum.json'
    f = File.open(fileName,"w")
    outData = { "results" => fftResults }
    f.puts "RESULTS=" << outData.to_json
    f.close

    # fftResults.each { |varr| 
    #     ifile++
    #     i=0
    #     varr.each { |v| 
    #         # lineOut = "#{i*freq}\t#{v}"
    #         puts v
    #         i+=1 
    #     }
    #     puts ''
    # }


end


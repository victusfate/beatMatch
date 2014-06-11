beatMatch - a little repo for dsp and beat matching ideas
===
so far its a ruby script that processes a soundtrack with a sliding window fft (fftw3 or slower but license free ruby impl) and dumps its outputs to spectrum.json which is plotted by plot.html using d3.js

will grow to add logic for specifying beat sections, with smooth/visually appealing beat drop off to a scale factor which can be applied to effects/visual properties

  usage: 
  	ruby beatMatch.rb file.wav
  	open plot.html

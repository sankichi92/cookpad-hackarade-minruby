MY_PROGRAM = 'interp.rb'

Dir.glob('test*.rb').sort.each do |f|
  correct = `ruby #{f}`
  output = `ruby #{MY_PROGRAM} #{f}`

  if output == correct
    puts "#{f} => OK!"
  else
    abort "#{f} => NG!"
  end
end

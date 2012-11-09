Ruby-Encrypt
============

A simple way to encrypt things, written with Ruby

I am currently trying to add RSA style encryption.




Notes:

#!/usr/bin/env ruby

#Resources:
  #http://mathcircle.berkeley.edu/BMC3/rsa/node4.html
  #http://www.javamex.com/tutorials/cryptography/rsa_encryption.shtml
  #http://en.wikipedia.org/wiki/RSA_%28algorithm%29#Decryption
  #For the decrypting raising to a power: http://en.wikipedia.org/wiki/Square-and-multiply_algorithm
  #http://en.wikipedia.org/wiki/Modular_multiplicative_inverse
  #Prime #s: http://www.bigprimes.net/archive/prime/8/

#PossiblyUsefulFunctions:
  #gcdext and invert from https://gist.github.com/2388745
  #(p-1)*(q-1) is called Euler's totient function, it gives the number of integers that are coprime of a positive number

  #This section hopes to compute pi however much I wish
  #a resource I could look at is http://rubyquiz.strd6.com/quizzes/202-digits-of-pi
  #pi= (4.0/(8*k+1)-2.0/(8*k+4)-1.0/(8*k+5)-1.0/(8*k+6)) / (16**k)

  #Pi = SUMk=0 to infinity 16-k [ 4/(8k+1) - 2/(8k+4) - 1/(8k+5) - 1/(8k+6) ].

  #ruby info:
  #http://www.ruby-lang.org/en/libraries/

  #Breaks the input string into pieces and converts to ascii
  splitcode=input.split(%r{\s*})





#Code that removes ascii that isn't letters:
      #  if ascii[i]>126
     #     ascii[i] += -(126-31)
      #end
  # Ascii greater than 126 or less than 31 aren't characters


   #   if ( ascii[i] >=  65 and ascii[i] <= 65+25 ) or ( ascii[i] >=  97 and ascii[i] <= 97+25 )



    #  else
    #      puts 'fail'
   #   end
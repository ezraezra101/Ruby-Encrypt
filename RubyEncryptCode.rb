#!/usr/bin/env ruby

unless Kernel.respond_to?(:require_relative)
  #borrowed from: http://stackoverflow.com/questions/4333286/ruby-require-vs-require-relative-best-practice-to-workaround-running-in-both
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

def rotate_13(input="hello world")
  decode= ''
  ascii=[]
  #converts to ascii
  input.each_byte do |c|
    ascii << c
  end

  for i in 0..ascii.length-1
    #Capital Letters
    if ascii[i]>=65 and ascii[i] <=90
      ascii[i]+=13
      if ascii[i]>90
        ascii[i] += -26
      end
    #lower case letters
    elsif ascii[i]>=97 and ascii[i]<=122
      ascii[i] +=13
      if ascii[i]>122
        ascii[i] += -26
      end
    end
    decode << ascii[i].chr
  end
  decode
end

#does rotate on the all printable ascii characters
def rotate_47(input="hello world")
  decode= ''
  ascii=[]
  #converts to ascii
  input.each_byte do |c|
    ascii << c
  end

  for i in 0..ascii.length-1
    if ascii[i]>=33 and ascii[i] <=126
      ascii[i]+=47
      if ascii[i]>126
        ascii[i] += -94
      end
    end
    decode << ascii[i].chr
  end
  decode
end

def pi_encrypt(input='hello world', to_code=true,seed=0)
  source = 3.1415926535897932384626433
  decode= ''
  ascii=[]
  #This picks whether you are doing or undoing code
  case to_code
    when false
      to_code_coefficient= -1
    when true
      to_code_coefficient = 1
  end
  #converts to ascii
  input.each_byte do |c|
    ascii << c
  end

  #Encodes/decodes and converts back to text
  splitsource =source.to_s.split(%r{\s*}) - ['.']
  for i in 0..ascii.length-1
    ascii[i] += to_code_coefficient * splitsource[i+seed].to_i
    decode << ascii[i].chr
  end
  decode
end


class RSA_encrypt
  def make(e)
    primes=primegen()
    keys=self.keygen(e,primes)
    @n, @e= keys[1]
    @privatekey=keys[0]
    self.keysave(keys)
  end

  def primegen()
    #primes = [43,257,61,167]
    primes = [4801,1031,1999,167, 7919, 7643, 2017]
    #primes = [61,53,23]
    #primes = [11,13]
    primes
  end

  def keygen(e,primes)
    n=1
    totient=1
    d_set=[]

    #Failsafe: if the totient is not coprime with e, stuff breaks
    for i in 0..primes.length-1
      if (primes[i]-1)%e==0
        puts "Change the prime #{primes[i]} or e \(#{e}\)"
        x=1
      end
    end
    if x==1
      quit
    end

    for i in 0..primes.length-1
      n*=primes[i]
      totient*=primes[i]-1
    end
    i=0

    while (i*totient+1)%e != 0
      i+=1
    end
    d= (totient*i + 1)/e

    #Chinese remainder algorithim keygen
    for i in 0..primes.length-1
      d_set[i]=d% (primes[i]-1)
    end

      #computing the inverse modulus of q & p only 2 primes at the moment
    #i=0
    #while (i*primes[0]+1)%primes[1] != 0
    #  i+=1
    #end
    #qinv=(i*primes[0] + 1)/primes[1]

    #made to work with more primes
    primesinverse=[]
    primesproduct=1
    for i in 0..primes.length-1
      x=0
      while (x*primesproduct + 1) % primes[i] != 0
        x+=1
      end
      primesinverse[i]= (x*primesproduct + 1)/primes[i]
      primesproduct*=primes[i]
    end

    #privatekey=[n,d] - for when not using the Chinese remainder decryption
    privatekey=[primesinverse, d_set, primes]
    publickey=[n,e]
    output=[privatekey, publickey]
    output
  end

  def encrypt_once(input, n=nil, e=nil)
    if n==nil
      n=@n
    end
    if e==nil
      e=@e
    end

    output=(input**e)%n
    output
  end

  #def decrypt(input, n, d)
  #  output=(input**d)%n
  #end
  def decrypt_once(input,primesinverse=nil,d_set=nil,primes=nil)#primesinverse=@privatekey[0],d_set=@privatekey[1],primes=@privatekey[2])
    if primesinverse or d_set or primes == nil
      primesinverse, d_set, primes =@privatekey
    end
    #Chinese remainder decryption:
    m=[]
    for i in 0..primes.length-1
      m[i]=(input**d_set[i]) % primes[i]
    end
    #this part works with only two primes
    #h=(qinv*(m[0]-m[1]))%primes[0]
    #output= m[1] + h*primes[1]
    #fixed to make work with more primes
    primesproduct=1
    tempoutput=0

    for i in 0..primes.length-1
      temph=(primesinverse[i]*(tempoutput-m[i]))%primesproduct
      tempoutput=m[i] + temph*primes[i]
      primesproduct*=primes[i]
    end

    output=tempoutput

    output
  end
=begin
  def test(mesg=65,e=17)
    self.make(e)
    encrypted=self.encrypt_once(mesg,$n,$e)
    puts mesg
    puts "encrypted"
    puts encrypted
    puts "decrypted"
    puts self.decrypt_once(encrypted,$privatekey[0],$privatekey[1],$privatekey[2])
    #puts "This function is broken"
    puts "keys"
    puts $n
    puts $d
    puts $e
    puts "*********"
  end
=end

  def keyload(key_file_path="rsa_private_key.rb")
    #require key_file_path
    require_relative key_file_path
    @n, @e= publickey
    @privatekey=privatekey
    #puts $n, $e, $privatekey
  end


  def keysave(keys=nil)
    if keys==nil
      keys=@privatekey,[@n,@e]
    end
    publickey= keys[1]
    privatekey=keys[0]
=begin
    puts "n, e"
    puts n, '\n', e
    puts 'privatekey'
    puts 'primesinverse'
    puts privatekey[0]
    puts 'd_set'
    puts privatekey[1]
    puts 'primes'
    puts privatekey[2]
=end

    private_key_file = File.new(File.dirname(caller[0])+"/"+"rsa_private_key.rb", "w")

    private_key_file.write("def privatekey()\n"+self.private_key_string(privatekey)+"\nend\ndef publickey()\n"+self.public_key_string(publickey)+"\nend")

    private_key_file.close

    #public_key_file = File.new("rsa_public_key.txt")
  end
=begin
  myStr = "This is a test"
  aFile = File.new("myString.txt", "w")
  #<File:myString.txt>
  aFile.write(myStr)
  aFile.close
  aFile=File.open("myString.txt", "w")
=end
  def private_key_string(privatekey)
    private_key_names=["primesinverses","d_set", "primes"]
    private_key_string="privatekey=["
    for i in 0..privatekey.length-1
      private_key_string << private_key_names[i]+"=["
      for x in 0..privatekey[i].length-1
        private_key_string << privatekey[i][x].to_s+","
      end
      private_key_string << "],\n"
    end
    private_key_string << "]"
    private_key_string
  end
  def public_key_string(publickey)
    n, e= publickey
    public_key_string="publickey=[n="+n.to_s+",e="+e.to_s+"]"
  end
  def encrypted_string(encrypted_array) #bad Should be changed
    string="["
    for i in 0..encrypted_array.length-1
      string << encrypted_array[i].to_s+","
    end
    string << "]"
    string
  end
  def encrypted_array(encrypted_string)
    array=[]
    for i in 0..encrypted_string.length-1
      array << encrypted_string[i].to_i
    end
    array
  end

  def split_input(input,n=nil)
    if n==nil
      n=@n
    end
    max_l=self.max_length(n)
    #puts max_l
    split_input=[]
    for i in 0..(input.length()/max_l)
      split_input << input[max_l*i,max_l]
    end
    split_input
  end


  def max_length(n=nil)
    if n==nil
      n=@n
    end
    #returns the number of bytes encrypted in a single run
    i=0
    while 128**i<=n
      i+=1
    end
    max_length=i-1
  end

  def encrypt_splits(input,n=nil,e=nil)
    if n or e == nil
      n=@n
      e=@e
    end

    split=self.split_input(input,n)
    encrypted=[]
    for i in 0..split.length-1
      split_int=shrink_message(split[i])
      #Requires shrink_message
      encrypted << self.encrypt_once(split_int,n,e)
    end
    encrypted
  end
  def decrypt_splits(input,primesinverse=nil,d_set=nil,primes=nil)#primesinverse=@privatekey[0],d_set=@privatekey[1],primes=@privatekey[2])
    if primesinverse or d_set or primes == nil
      primesinverse, d_set, primes =@privatekey
    end

    decrypted=''
    for i in 0..input.length-1
      split_int=self.decrypt_once(input[i],primesinverse,d_set,primes)
      #Requires unshrink
      decrypted << unshrink(split_int)
    end
    decrypted
  end

  def keysnil?()
    to_return=""
    if @n and @e and @privatekey !=nil
      to_return=false
    else
      if @n==nil
        to_return << "n "
      end
      if @e==nil
        to_return << "e "
      end
      if @privatekey==nil
        to_return << "privatekey "
      end
      to_return
    end
  end
  def keyclear()
    @n,@e,@privatekey=nil,nil,nil
  end

end


def shrink_message(mesg)
  ascii=[]
  shrinked=0
  #converts to ascii
  mesg.each_byte do |c|
    ascii << c
  end
  #converts ascii into a integer, basically it concatinates what ascii is in base 128
  length=ascii.length
  for i in 1..length
    shrinked+=ascii[length-i]*128**(i-1)
  end
  shrinked
end

def shrink_mesg_1(mesg)
  #does not work properly
  ascii=[]
  shrinked=''
  #converts to ascii
  mesg.each_byte do |c|
    ascii << c
  end
  for i in 0..ascii.length-1
    byte_letter = ascii[i].to_s(2)
    if byte_letter.length < 7
      for x in 1..7-byte_letter.length
        byte_letter='0'+byte_letter
      end
    end
    shrinked << byte_letter

    #shrinked+=ascii[i]*128**(i)
  end
  shrinked.to_i(2)
end

def unshrink_mesg_1(mesg)
  #does not unshrink properly when the first character is less than 64ish
  decode=''
  ascii=[]
  mesg=mesg.to_s(2)
  for i in 0..mesg.length/7-1
    ascii << mesg[i*7,7].to_i(2)
    decode << ascii[i].chr
    #ascii[i]=mesg % (128**i)
    #mesg=(mesg-ascii[i])/128
    #decode << ascii[i].chr
  end
  decode
end

def unshrink(mesg)
  decode=''
  ascii=[]

  length=1
  while 128**length<=mesg
    length+=1
  end

  for i in 1..length
    ascii << mesg/(128**(length-i))
    mesg=mesg % (128**(length-i))
    decode << ascii[i-1].chr
  end

  decode
end

#This should take user input
def run()
  STDOUT.flush
  puts 'Paste your message in here'
  input = gets.chomp
  puts 'Are you doing a rotate 13 cipher? Y/N'
  typeofencode=gets.chomp
  case typeofencode
  when 'Y', 'y', 'yes', 'Yes'
    to_code=13
    puts 'Here is your encrypted text:'
    puts rotate_13(input)
  else
    puts 'What is your seed? (0 for none)'
    seed=gets.chomp.to_i
    puts 'Are you decoding? Y/N'
    encoding=gets.chomp
    case encoding
    when 'Y', 'y', 'yes', 'Yes'
      to_code=true
    else
      to_code=false
    end
    puts 'Here is your encrypted text:'
    puts pi_encrypt(input,to_code,seed)
  end
  puts 'would you like to encode more? Y/N'
  again=gets.chomp
  case again
  when 'Y', 'y', 'yes', 'Yes'
    run()
  else
    puts 'Bye'
  end
end

def RSA_run(mesg="hello world", load=true)
  STDOUT.flush
  rsa=RSA_encrypt.new()

  case load
  when true
    rsa.keyload()
  else
    rsa.make(17)
  end
  


  max_length=rsa.max_length() #auto uses @n
  puts "This encryption can only take about #{max_length} characters"

  encrypted=rsa.encrypt_splits(mesg) #auto includes @n & @e
  puts "Encrypted text:\n"+encrypted.to_s
  decrypted=rsa.decrypt_splits(encrypted) #auto includes "@privatekey"<\paraphrase>
  puts "Decrypted text:\n"+decrypted
=begin
  mesg_int=shrink_message(mesg)
  puts "broken"
  encrypted=rsa.encrypt(mesg_int,$n,$e)
  #encrypted=rsa.encrypt_splits(mesg_int,$n,$e)
  puts "encrypted"
  puts encrypted
  #decrypted=rsa.decrypt(encrypted,$n,$d)
  puts "broken"
  decrypted=rsa.decrypt(encrypted,$privatekey[0],$privatekey[1],$privatekey[2])
  #decrypted=rsa.decrypt_splits(encrypted,$privatekey[0],$privatekey[1],$privatekey[2])
  puts "Decrypted integer"
  puts decrypted
  puts "Decrypted message"
  puts unshrink(decrypted)
=end

end

def RSA_ask()
  puts "Load keys? Y/N"
  loadq=gets.chomp
  case loadq
  when 'Y', 'y', 'yes', 'Yes'
    load=true
  else
    load=false
  end

  puts "Input Message"
  mesg=gets.chomp

  RSA_run(mesg, load)

  puts "again? Y/N"
  again=gets.chomp
  case again
  when 'Y', 'y', 'yes', 'Yes'
    RSA_ask()
  else
    puts 'Bye'
  end
end

def RSA_no_q_run(mesg="hello world", encrypting=true, load="")
  STDOUT.flush
  rsa=RSA_encrypt.new()

  case load
  when true
    rsa.keyload()
  when false
    rsa.make(17)
  else
    begin
      rsa.keyload()
    rescue
      rsa.make(17)
    end
  end

  case encrypting
  when true
    output=rsa.encrypt_splits(mesg) #auto includes @n & @e
  else
    output=rsa.decrypt_splits(mesg) #auto includes "@privatekey"<\paraphrase>
  end
end

if __FILE__==$0
  RSA_ask()
  #run()
end

#For Hacking:
#decrypt(2790,[1,38],[53,49],[61,53])
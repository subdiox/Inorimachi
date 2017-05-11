require "open3"

puts "This script downloads all data of inori machi."

email = ""
password = ""
if ARGV.count == 2 then
    email = ARGV[0]
    password = ARGV[1]
else
    print "Email: "
    email = gets.to_s
    print "Password: "
    password = gets.to_s
end

o1, e1, s1 = Open3.capture3("curl -s -L -c cookie.txt \'https://mobile-ssl.com/s/sma01/login\' | grep my_webckid | cut -d \'\"\' -f6")
my_webckid = o1
o2, e2, s2 = Open3.capture3("curl -X POST -c cookie.txt -b cookie.txt -d \'idpwLgid=" + email + "\' -d \'idpwLgpw=" + password "\' -d \'my_prevtyp=W\' -d \'my_prevdom=smam.jp\' -d \'my_prevurl=/s/sma01/course\' -d \'my_prevmet=GET\' -d \'my_webckid=" + my_webckid + "\' -d \'my_prevprm=\' -d \'mode=LOGIN\' -d \'ima=4114\' \'https://mobile-ssl.com/s/sma01/login\'")
o3, o3, s3 = Open3.capture3("wget --load-cookies=cookie.txt -r \'http://smam.jp\'")

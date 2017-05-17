require "open3"
require "io/console"
require "FileUtils"

puts "This script downloads all data of inori machi."
email = ""
password = ""
if ARGV.count == 2 then
    email = ARGV[0]
    password = ARGV[1]
    puts "----------------------------------------------"
    puts "  Email: " + email
    print "  Password: "
    password.length.times do
        print "*"
    end
    puts ""
    puts "----------------------------------------------"
else
    puts "----------------------------------------------"
    print "  Email: "
    email = gets.to_s.chomp
    print "  Password: "
    password = STDIN.noecho(&:gets).chomp
    password.length.times do
        print "*"
    end
    puts ""
    puts "----------------------------------------------"
end
command = "curl -s -L -c cookie.txt \'https://mobile-ssl.com/s/sma01/login\' | grep -e \'my_webckid\' -e \'name=\"ima\"\' | cut -d \'\"\' -f6"
o, e, s = Open3.capture3(command)
o_array = o.split("\n")
my_webckid = o_array[0]
ima = o_array[1]

command = "curl -s -X POST -c cookie.txt -b cookie.txt -d \'idpwLgid=" + email + "\' -d \'idpwLgpw=" + password + "\' -d \'my_prevtyp=W\' -d \'my_prevdom=smam.jp\' -d \'my_prevurl=/s/sma01/course\' -d \'my_prevmet=GET\' -d \'my_webckid=" + my_webckid + "\' -d \'my_prevprm=\' -d \'mode=LOGIN\' -d \'ima=" + ima + "\' \'https://mobile-ssl.com/s/sma01/login\' | grep \'idpwLgid\' | wc -l"
o, e, s = Open3.capture3(command)

if o.to_i > 0 then
    puts "Login Failed. Please confirm that your email and password are valid."
    exit
end

command = "curl -b cookie.txt \'http://smam.jp/s/sma01/course\'"
o, e, s = Open3.capture3(command)

puts "Login Succeeded."
puts "Started downloading data..."

puts "What do you want to download? (1.まちの放送局, 2.まちの映画館) [1]"
input = gets.to_i
if input == 2 then
    FileUtils.mkdir_p("まちの映画館")

    i = 0
    array = []
    loop do
        command = "curl -s -b cookie.txt \'http://smam.jp/s/sma01/artist/1725/contents?ima=1536&page=" + i.to_s + "&ct=1725_134_1\' | grep -e \'<li><a href=\' -e \'<p class=\"title\">\'"
        o, e, s = Open3.capture3(command)
        o_array = o.split("\n")
        if o_array.count < 2 then
            break
        else
            each_array = []
            o_array.each_with_index do |val, index|
                if index % 2 == 0 then
                    command = "echo \'" + val + "\' | cut -d \'\"\' -f2"
                    o, e, s = Open3.capture3(command)
                    each_array.push(o)
                else
                    command = "echo \'" + val + "\' | cut -d \'>\' -f2 | cut -d \'<\' -f1"
                    o, e, s = Open3.capture3(command)
                    each_array.push(o)
                    array.push(each_array)
                    each_array = []
                end
            end
        end
        i += 1
    end

    array.each do |val|
        video_id = val[0].split("/")[4].split("?")[0]
        title = val[1].chomp.gsub("/", ":").strip
        command = "youtube-dl -o \'まちの映画館" + File::Separator + title + ".mp4\' \'http://players.brightcove.net/4504957038001/default_default/index.html?videoId=ref\:\'" + video_id
        Open3.popen3(command) do |i, o, e, w|
            o.each do |line| puts line end
            e.each do |line| puts line end
        end
    end
else
    FileUtils.mkdir_p("まちの放送局")

    i = 0
    array = []
    loop do
        command = "curl -s -b cookie.txt \'http://smam.jp/s/sma01/artist/1725/contents?ima=0545&page=" + i.to_s + "&ct=1725_134_2\' | grep -e \'<li><a href=\' -e \'<p class=\"title\">\'"
        o, e, s = Open3.capture3(command)
        o_array = o.split("\n")
        if o_array.count < 2 then
            break
        else
            each_array = []
            o_array.each_with_index do |val, index|
                if index % 2 == 0 then
                    command = "echo \'" + val + "\' | cut -d \'\"\' -f2"
                    o, e, s = Open3.capture3(command)
                    each_array.push(o)
                else
                    command = "echo \'" + val + "\' | cut -d \'>\' -f2 | cut -d \'<\' -f1"
                    o, e, s = Open3.capture3(command)
                    each_array.push(o)
                    array.push(each_array)
                    each_array = []
                end
            end
        end
        i += 1
    end

    array.each do |val|
        video_id = val[0].split("/")[4].split("?")[0]
        title = val[1].chomp.gsub("/", ":").strip
        command = "youtube-dl -o \'まちの放送局" + File::Separator + title + ".mp4\' \'http://players.brightcove.net/4504957038001/default_default/index.html?videoId=ref\:\'" + video_id
        Open3.popen3(command) do |i, o, e, w|
            o.each do |line| puts line end
            e.each do |line| puts line end
        end
    end
end

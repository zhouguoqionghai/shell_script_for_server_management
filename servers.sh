#!/bin/bash


full_path=~/
source "${full_path}set_environ.sh"

declare -A arr
OLD_IFS=$IFS
IFS=";"
row_count=0

shopt -s extglob
while read tmp
do
  column=0
  tmp_arr=(${tmp})
  while ((column < ${#tmp_arr[*]}))
  do
    val=${tmp_arr[$column]}
    #val=$(sed "s/[[:space:]]*$//g" <<< "$val") #去掉开头空白符  
    #val=$(sed "s/^[[:space:]]*//g" <<< "$val") #去掉末尾的空白符

    #val=${val##*([[:space:]])} #sed 效率过低，10s左右才结束。
    #val=${val%%\$([[:space:]])}
	
	[[ $val =~ [[:space:]]*(.*[^[:space:]])[[:space:]]*  ]] && val=${BASH_REMATCH[1]}   #或者使用正则表达式
    arr[$row_count,$column]=$val
    ((++column))
  done
  column=0

  ((++row_count))
done << EOF
159.159.159.159;    22;          香港跳板机;                香港华为云
138.138.138.138 ;	22;		    香港Over;                   香港华为云  
192.168.1.12   ; 	234;		    公司内网;                  1.12内网,版本发布机器
EOF

# ip               端口         PS1 命令提示符                备注
# 定格式添加 使用;分割   一共四列 

shopt -u extglob #关闭 extglob

IFS=${OLD_IFS}
unset OLD_IFS


function servs()
{
    echo "sv 直接登陆 jsv 跳转；sftp 直接 sftps ；jsftp 跳转传送"
	{
		for((m=0;m<row_count;++m))
		do
			if((m % 3 == 0));then
				printf "\033[31m%-2s:|%s| %s\033[0m\n"  "${m}" "${arr[$m,2]}_${arr[$m,3]}" "${arr[$m,0]}" #红色
			elif((m % 3 == 1));then
				printf "\033[32m%-2s:|%s| %s\033[0m\n"  "${m}" "${arr[$m,2]}_${arr[$m,3]}" "${arr[$m,0]}" #绿色
			else
				printf "\033[34m%-2s:|%s| %s\033[0m\n"  "${m}" "${arr[$m,2]}_${arr[$m,3]}" "${arr[$m,0]}" #蓝色
			fi
		done
	} | column -s "|" -t
}

export arr
export -f servs
echo "#!/bin/bash" > "${full_path}xxx.sh" #清空文件



base_ip="131.131.131.131" #跳转机ip
base_port="22" #跳转机端口


for((m=0;m<row_count;++m)) #注意 shell 中多行字符串的写法  同python 中的 """ 类似 """
do
    funcstr="
sv${m}()
{ 
    #${arr[$m,2]}
	local bb=\"bash --rcfile <(cat ~/.bashrc ; echo \\\"PS1=\\\\\\\"[\u@\${arr[$m,2]}\[\e[32m\]$ip\[\e[0m\] \[\e[33m\]\w\[\e[0m\]]\$\\\\\\\"\\\")\"
	ssh -t -p ${arr[$m,1]} root@\${arr[$m,0]} \${bb} 
}"
    echo "${funcstr}" >> "${full_path}xxx.sh"
    echo "export -f sv${m}" >> "${full_path}xxx.sh"

    bsstr="
jsv${m}()
{ 
    #${arr[$m,2]}
	local bb=\"\\\"bash --rcfile <(cat ~/.bashrc ; echo \\\\\\\"PS1=\\\\\\\\\\\\\\\"[\u@\${arr[$m,2]}\[\e[32m\]$ip\[\e[0m\] \[\e[33m\]\w\[\e[0m\]]\$\\\\\\\\\\\\\\\"\\\\\\\")\\\"\"
	ssh -t -p ${base_port} root@${base_ip} \"ssh -t -p ${arr[$m,1]} root@${arr[$m,0]} \${bb}\"
}"
    echo "${bsstr}" >> "${full_path}xxx.sh"
    echo "export -f jsv${m}" >> "${full_path}xxx.sh"


    ftpstr="
sftp${m}()
{ 
    #sftp ${arr[$m,2]}
	sftp -P ${arr[$m,1]} root@\${arr[$m,0]}
}"
    echo "${ftpstr}" >> "${full_path}xxx.sh"
    echo "export -f sftp${m}" >> "${full_path}xxx.sh"

    jmp_ftpstr="
jsftp${m}()
{ 
    #jmp sftp ${arr[$m,2]}
	sftp -J root@${base_ip} root@\${arr[$m,0]}
}"
    echo "${jmp_ftpstr}" >> "${full_path}xxx.sh"
    echo "export -f jsftp${m}" >> "${full_path}xxx.sh"

done

source "${full_path}xxx.sh" #加载所有的登陆函数


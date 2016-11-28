#!/bin/bash

#################################################################################
#
#  snake.sh
#  ------------------
#  Copyright 2014, LingYi (lydygly@163.com) QQ:1032558409
#  No web site now.
#
#  "snake.sh" comes with ABSOLUTELY NO WARRANTY. This is free software, and you are
#  welcome to redistribute it under the terms of the GNU General Public License.
#  See LICENSE file for usage of this software.
#  
#  "snake.sh" is a game for Unix based operating systems.
#
#################################################################################
#
#  date : 2014.06.09
#  Usg  : sh snake.sh or  sh snake.sh -h 
#
#################################################################################
#

help(){
    cat<<EOF
    you can use arrow keys in keyboard to play the game.
    of course , the keys  'W' 'S' 'A' 'D'  or 'I' 'K' 'J' 'L'  work. 
	
    q/Q     To quit the game. If you use the 'r' option, 
            you may need to press Q key several times.
    r/R     Restart the game
    g/G     When the game is running, if the random point does not appear, 
            you can press it to get one or many ~. [ No turn on ]
    [ c/C ] If you have got many random points by using 'R', you can use 
            it to clear them. But do not recommend to use it!! []
    p       Slow down. Sleep time reflects.
    P       Speed up. Sleep time reflects.
    NOTE: About the position of an new random point , have not made a judgment.
EOF
}
 
init_inv(){
    trap ' ' 2
    tput cup 0 0; tput ed; tput civis
    lines=`tput lines`
    cols=`tput cols`
    # red:41 green:42 orange:43 blue:44  pink:45 lit_blue:46  white:47
    snake_head_color=41
    snake_body_color=42	
    #random_point_color=''
    snake_head_symbol=' '
    snake_body_symbol=' '
    random_point_symbol=' '
    boundary_symbol=' '
    direction=''
    random_point=()
    points=(4 1)
    head_point=(4 1)
    sleep_time=0.3
    sleep_time_log=/mnt/.1.log
    state_log=/mnt/.2.log
    points_log=/mnt/.3.log
    random_point_log=/mnt/.4.log
    echo $sleep_time >$sleep_time_log
    echo running >$state_log
    echo ${points[0]} ${points[1]} >$points_log
    echo >$random_point_log
    for((i=1;i<=cols;i++)); do echo -e "\033[3;${i}H\033[1;41m${boundary_symbol}\033[0m"; done
    for((i=1;i<=cols;i++)); do echo -e "\033[$((lines - 1));${i}H\033[1;41m${boundary_symbol}\033[0m"; done
    echo -e "\033[${head_point[0]};${head_point[1]}H\033[${snake_head_color}m${snake_head_symbol}\033[0m"
    get_head_random_point random
    print_info &
    score_PID=$!
}

print_info(){
    while :; do
        DATE=`date +"%Y-%m-%d %H:%M:%S"`
        echo -e "\033[1;1H$DATE\033[0m "
        points=(`cat $points_log`)
        score=$(( ${#points[@]} / 2 ))
        echo -ne "\033[1;24H"
        echo -ne "\033[1;35mscore:\033[33m[ \033[1;32m$score\033[1;33m ]\033[1;38H\033[1;35m  state:\033[032m`cat $state_log`"    
        echo -ne "\033[1;55H\033[1;35m  sleep time:\033[032m$(cat $sleep_time_log)"		
        echo -e "\033[2;1H\033[1;5;36m[r]:restart [g]:new point [Space]:pause [P]:speed up [p]:slow down  \033[0m "
        sleep 1
    done	
}

get_head_random_point(){
    [[ $1 == 'random' ]] && {
        while :; do 
            line=$(( $RANDOM % ( $lines - 3 ) + 4 ))
            col=$(( $RANDOM % ( $cols - 1 ) + 1 )) 
            random_point_color=4$(( $RANDOM % 6 + 1))			
            [[ $line -lt $((lines - 1))  ]]  && {
                echo -e "\033[${line};${col}H\033[${random_point_color}m${random_point_symbol}\033[0m"
                echo $line $col >>$random_point_log
                break
            }	
        done
    }   ||  {
            points=(`cat $points_log`)
            lenth_points=${#points[@]}
            first_pos=$((lenth_points - 2))
            second_pos=$((lenth_points - 1))
            head_point=(${points[$first_pos]} ${points[$second_pos]})   
    }
}

change_add_points(){
   points=(`cat $points_log`)
   lenth_points=${#points[@]}
   case $1 in
      'change') 
              shift		     
              if [[ $lenth_points -eq 2 ]]; then
                  points=($1 $2)
              else
                  for((i=0;i<=lenth_points-1;i++)); do
                      j=$(( i+2 ))
                      [[ $j -gt $(( lenth_points-1 )) ]] && [[ $((i%2)) -eq 0 ]] && points[$i]=$1 && continue
                      [[ $j -gt $(( lenth_points-1 )) ]] && [[ $((i%2)) -eq 1 ]] && points[$i]=$2 && continue
                      points[$i]=${points[$j]} 
                  done
              fi
              ;;
        'add')
              shift		
              add_one=$lenth_points
              add_two=$(( add_one + 1 ))
              points[$add_one]=$1
              points[$add_two]=$2
              lenth_points=${#points[@]} 		
              ;;
    esac				
    echo ${points[@]} >$points_log	
}

print_clear_points(){
    if [[ $1 == 'clear_random_point' ]]; then
        random_point_moument=(`cat $random_point_log|xargs`)
        length=${#random_point_moument[@]}
        for((i=0; i<=length-2; i++)); do
            j=$((i+1))
            echo -e "\033[${random_point_moument[$i]};${random_point_moument[$j]}H \033[0m"
        done
        echo >$random_point_log
        get_head_random_point random	
    else    				
        points=(`cat $points_log`)
        lenth_points=${#points[@]} 
        for((i=0;i<=lenth_points-2;i+=2)); do
            j=$((i+1))
            if [[ $i == $((lenth_points - 2)) ]]; then
                [[ $1 == 'print' ]] && echo -e "\033[${points[$i]};${points[$j]}H\033[${snake_head_color}m${snake_head_symbol}\033[0m"
            else		
                [[ $1 == 'print' ]] && echo -e "\033[${points[$i]};${points[$j]}H\033[${snake_body_color}m${snake_body_symbol}\033[0m"
            fi			
	     	[[ $1 == 'clear' ]] && echo -e "\033[${points[$i]};${points[$j]}H \033[0m"		
        done
    fi		
}

change_speed(){
    sleep_time=`cat $sleep_time_log`
    if [[ $1 == 'up' ]]; then 
        sleep_time=`echo $sleep_time - 0.1 | bc`
        [[ `echo "${sleep_time}*10"|bc|awk -F. '{print $1}'` -le 0 ]] && sleep_time=0.0		
    elif [[ $1 == 'down' ]]; then
        sleep_time=`echo $sleep_time + 0.1| bc`	
    fi
    if echo $sleep_time | grep '^\.' >/dev/null 2>&1; then sleep_time="0$sleep_time"; fi
    echo $sleep_time >$sleep_time_log	
}

judge_touch(){
    case  $1 in 
        'points') 	
                shift		
                points=(`cat $points_log`)
                len=${#points[@]}
                for((i=0;i<=len-2;i+=2));do
                    j=$(( i + 1 ))
                   [[ ${points[$i]} == $1 ]] && [[ ${points[$j]} == $2 ]] &&  return 0 
                done
                ;;
        'random_point')
                shift		
                random_point=(`cat $random_point_log|xargs`)
                len=${#random_point[@]}
                for((i=0;i<=len-2;i+=2));do
                    j=$(( i + 1 )) 
                    [[ ${random_point[$i]} == $1 ]] && [[ ${random_point[$j]} == $2 ]] &&  return 0
                done
                ;;
    esac				
}

change_dir(){
    print_clear_points clear
    get_head_random_point head
        while :; do 
        case $1 in
            'up'   )  let head_point[0]-- ;;
            'down' )  let head_point[0]++ ;;
            'left' )  let head_point[1]-- ;;
            'right')  let head_point[1]++ ;;
        esac	
        #touch itself, game over
        judge_touch points ${head_point[0]} ${head_point[1]} && exit_game
        if judge_touch random_point ${head_point[0]} ${head_point[1]}; then 
            sed -i "s/${head_point[0]} *${head_point[1]}//g; /^$/d" $random_point_log
            change_add_points add ${head_point[0]} ${head_point[1]}; get_head_random_point random
        else 
            change_add_points change ${head_point[0]} ${head_point[1]}
        fi	
        #touch boundary, game over
        case $1 in
            'up'   )  [[ ${head_point[0]} == 3 ]] &&  exit_game back ;;
            'down' )  [[ ${head_point[0]} == $((lines - 1 )) ]] && exit_game back ;;
            'left' )  [[ ${head_point[1]} == 0 ]] && exit_game back ;;
            'right')  [[ $((head_point[1] -1)) == $cols ]] && exit_game back ;;
        esac
        print_clear_points  print
        sleep `cat $sleep_time_log`; print_clear_points clear
    done 

}

control_dir(){
    case $1 in
      'up'   ) second_dir='down' ;;
      'down' ) second_dir='up'   ;;
      'left' ) second_dir='right';;
      'right') second_dir='left' ;;	  
    esac
    if [[ $direction != $second_dir  ]]; then
        echo running >$state_log    
        direction=$1
        [[ -n $game_pid ]] && kill -9 $game_pid
        change_dir $1  & 
        game_pid=$!
    fi
}

get_key(){
    ESC=`echo -e '\033'`
    stty -echo
    while :; do
        read -s -n 1 key
        [[ $key == 'P' ]] && change_speed up
        [[ $key == 'p' ]] && change_speed down			
        key=`echo $key | tr 'a-z' 'A-Z'`
        [[ $key == 'Q' ]] && exit_game		
        [[ $key == 'R' ]] && ( kill -9 $game_pid; sh $0 )
        #[[ $key == 'C' ]] && print_clear_points clear_random_point		
 
        [[ $key == 'G' ]] && get_head_random_point random &
        [[   -z $key   ]] && (echo pausing >$state_log; kill -9 $game_pid )
        [[ $key == 'W' ]] || [[ $key == 'I' ]] && control_dir up
        [[ $key == 'S' ]] || [[ $key == 'K' ]] && control_dir down
        [[ $key == 'D' ]] || [[ $key == 'L' ]] && control_dir right
        [[ $key == 'A' ]] || [[ $key == 'J' ]] && control_dir left
		
        [[ $key == $ESC ]] && {
            for (( i=0; i<=1; i++ )); do read -s -n 1  KEY[$i]; done
            [[ ${KEY[0]} == $ESC  ]] &&  exit_game			
            [[ ${KEY[0]} == '['   ]] && {
                [[ ${KEY[1]} == 'A' ]] &&  control_dir up
                [[ ${KEY[1]} == 'B' ]] &&  control_dir down
                [[ ${KEY[1]} == 'C' ]] &&  control_dir right
                [[ ${KEY[1]} == 'D' ]] &&  control_dir left
            }
        }
    done 2>/dev/null
}

exit_game(){
    kill -9 $game_pid  $score_PID
    rm -fr $points_log  $random_point_log  $state_log $sleep_time_log
    stty echo
    line_posi=$(( lines / 2 -2 ))
    col_posi=$(( cols / 2 -12 ))
    echo -e "\033[$((line_posi + 0 ));${col_posi}H\033[31m-------------------------\033[0m"
    echo -e "\033[$((line_posi + 1 ));${col_posi}H\033[31m|                       |\033[0m"
    echo -e "\033[$((line_posi + 2 ));${col_posi}H\033[31m|      Snake Dead       |\033[0m"
    echo -e "\033[$((line_posi + 3 ));${col_posi}H\033[31m|                       |\033[0m"
    echo -e "\033[$((line_posi + 4 ));${col_posi}H\033[31m-------------------------\033[0m"	
    tput cnorm; exit 0
}
#
#################################################################################
#
#                          Exection Body
#
#################################################################################
#
   [[ $1  ==  '-h' ]] && help && exit 
   init_inv 
   get_key




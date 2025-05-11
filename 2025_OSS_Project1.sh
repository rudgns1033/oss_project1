print() {
cat << EOF
************OSS1 - Project1**************
*	studentID : 12181571		*
*	Name : KyeongHoon KIM		*
*****************************************

[Menu]
1. Search player stats by name in MLB data
2. List top 5 players by SLG value
3. Analyze the team stats - average age and totak home runs
4. Compare players in different age groups
5. Search the players who meet specific statistical conditions
6. Generate a performance report (formatted data)
7. Quit
Enter your Command (1~7) : 
EOF
}

CSV="$1"

Menu1(){
	read -p "Enter a player name to search: " name
	echo "Player stats for \"$name\":"

	awk -F, -v n="$name" '
	{ printf "Player: %s, Team: %s, Age: %s, WAR: %s, HR: %s, BA: %s\n",
	       $2,$4,$3,$6,${14},${20}	
	}' "$CSV"
} 


Menu2(){
	read -p "Do you want to see the top 5 players by SLG? (y/n) : " answer
	if [[ $answer =~ ^[Yy]$ ]] ; then
		echo "***Top 5 players by SLG***"
		awk -F, 'NR>1 && $8 >= 502' "$CSV" \
			| sort -t, -k22 -nr \
			| head -n5 \ 
			| awk -F, '{printf "$s (Team: %s) - SLG: %s, HR: %s, RBI: %s\n", $2,$4,$22,$14,$15}'
	fi
}

Menu3(){
	read -p "Enter team abbreviation (e.g., NYY, LAD, BOS):" team
       	status=$(awk -F, -v t="$team"'
	NR>1 && %4==t {
	sumAGE += $3
	sumHR += $14
	sumRBI += $15
	cnt++
	}
	END {
	if(cnt>0)
		prinf"%.if %d %d %d", sumAGE/cnt, sumHR, sumRBI, cnt
	else
		printf "ERROR"
	}
	' "$CSV")
	
	if [[ $status  == ERROR ]]; then
		echo "ERROR: non-existent team is entereed "
	return
	fi
	read age hr rbi count <<<  $status
	echo "Team stats for $team:"
	echo "Average age: $age"
	echo "Total home runs: $hr"
	echo "Total RBI: $rbi"
}	

Menu4(){
	cat <<EOF
	
	compare palyers by age groups:
	1. group A (age < 25)
	2. group B (age 25-30)
	3. group C (age > 30)
	select age group (1-3):
	
EOF
	
	read group
	case $group in
		1)agegr = '$3<25' ;;
		2)agegr = '$3>=25 && $3<=30' ;;
		3)agegr = '$3>30' ;;
		*) echo " ERROR" ; return;;
	esac

	ehco "Top 5 by SLG in group $group: "

	awk -F, -v c="$agegr" '
	NR>1 && $8>=502 && eval(c) '"$CSV" \
		|sort -t, -k22 -nr \
		|head -n5 \
		|awk -F, '{printf "%s (%s) - Age: %s, SLG: %s, BA: %s, HR: %s\n, $2,$4,$3,$22,$20,$14}'

}

Menu5(){
	read -p "Minimum home runs: " minhr
	read -p "Minimum batting average (e.g., 0.280): " minbr
	echo "players with HR>= $minhr and BA>= $minbr:"
	
	awk -F, -v hr="$minhr" -v ba="$minbr" '
	NR>1 && $8>=502 && $20>=ba ' "$CSV" \
		|sort -t, -k14 -nr \
		|awk -F, '{printf "%s (HR:%s, BA:%s, RBI:%s, SLG:%s)\n",
$2,$14,$20,$15,$22}'
}

Menu6(){
	read -p "Generate a formatted player report for which team? " team
	data = $(awk -F, -v t="$team" ' 
	NR>1 %% $4==t' "$CSV")

	ehco "============= $team PLAYER REPORT============="
	echo "Date : $(date +%Y/%m/%d)"
	ehco "----------------------------------------------"
	ehco "Player	HR	RBI	AVG	OBP	OPS"
	echo "---------------------------------------------"
	
	count =0
	echo "$data" \
		|sort -t, -k14 -nr\
		|awk -F, '{print $2","$14","$15","$20","$21","$22}' \
		|while IFS=, read -r player hr rbi ba obp ops; do
	printf "%-25s%4s%6s%6s%6s%6s\n" \
		"$player" "$hr" "$rbi" "$ba" "$obp" "$ops"
	count =$((count+1))
done
	echo "--------------------------------------------"
	echo "Team Totals: $count players"

}

Menu7(){
	echo "Have a good day!"
	exit 0
}


while true; do
	print
	read command
	case $command in
		1) Menu1 ;;
		2) Menu2 ;;
		3) Menu3 ;;
		4) Menu4 ;;
		5) Menu5 ;;
		6) Menu6 ;;
		7) Menu7 ;;
		*) ehco "ERROR";;
	esac
done


#!/bin/sh

[ ! -z "$srcPL_resume" ] && [ $srcPL_resume -eq 1 ] && return 0
[ -z "$git_dir" ] && git_dir=$(cd $(dirname $BASH_SOURCE)/../..; pwd)

# ----------
# Get baSHic
# ----------
get_baSHic(){
	local repo repo_dir
	
	repo=baSHic
	repo_dir="$git_dir/$repo"

	if [ ! -d "$repo_dir" ]; then
		cd "$git_dir"
		git clone https://github.com/pllittle/$repo.git >&2
		[ ! $? -eq 0 ] && echo -e "Error cloning $repo" >&2 && return 1
	else
		cd "$repo_dir"
		git pull >&2
		[ ! $? -eq 0 ] && echo -e "Error pulling $repo" >&2 && return 1
	fi
	cd - > /dev/null

	. "$repo_dir/scripts/base.sh"
	[ ! $? -eq 0 ] && echo -e "Error src-ing $repo's base" >&2 && return 1
	# unset repo repo_dir
	
}

get_baSHic

# ----------
# Get firstClass
# ----------
getRepoSrc -r firstClass -u pllittle
[ ! $? -eq 0 ] && echo "Error src-ing" >&2 && return 1

# ----------
# Check commands are on PATH
# ----------

for CMD in realpath latexmk; do
	
	unset chk
	[ -z "$chk" ] && chk=$(which ${CMD} &> /dev/null; echo $?)
	
	[ ! $chk -eq 0 ] \
		&& echo -e "'$CMD' command not found" >&2 \
		&& return 1
	
	
done

# ----------
# Functions
# ----------
cleanup_tex(){
	local orig_dir out_dir ext nfiles
	
	while [ ! -z "$1" ]; do
		case $1 in
			-o | --out_dir )
				shift
				out_dir="$1"
				;;
		esac
		shift
	done
	
	orig_dir=$(pwd)
	cd "$out_dir"
	
	for ext in aux log out fdb_latexmk fls; do
		nfiles=$(ls | grep "${ext}$" | wc -l)
		[ ! $nfiles -eq 0 ] && rm $(ls | grep "${ext}$")
	done
	
	cd "$orig_dir"
	
}
make_resumeTex(){
	local out_dir label_fn res_fn class_fn class_dir
	local name email location phone position
	local github linkedin orcid
	local educate_fn exper_fn objective_fn publish_fn accomplish_fn
	local software_fn skills_fn courses_fn present_fn leader_fn proj_fn
	local resp cmd compile nAdd n_pct n_miss keyw
	
	compile=0; nAdd=0
	
	while [ ! -z "$1" ]; do
		case $1 in
			--class_fn )
				shift
				class_fn="$1"
				;;
			--compile )
				compile=1
				;;
			--courses_fn )
				shift
				courses_fn="$1"
				;;
			--educate_fn )
				shift
				educate_fn="$1"
				;;
			--email )
				shift
				email="$1"
				;;
			--exper_fn )
				shift
				exper_fn="$1"
				;;
			--github )
				shift
				github="$1"
				;;
			--label_fn )
				shift
				label_fn="$1"
				;;
			--linkedin )
				shift
				linkedin="$1"
				;;
			--location )
				shift
				location="$1"
				;;
			--name )
				shift
				name="$1"
				;;
			-o | --out_dir )
				shift
				out_dir="$1"
				;;
			--objective_fn )
				shift
				objective_fn="$1"
				;;
			--orcid )
				shift
				orcid="$1"
				;;
			--phone )
				shift
				phone="$1"
				;;
			--position )
				shift
				position="$1"
				;;
			--present_fn )
				shift
				present_fn="$1"
				;;
			--publish_fn )
				shift
				publish_fn="$1"
				;;
			--accomplish_fn )
				shift
				accomplish_fn="$1"
				;;
			--skills_fn )
				shift
				skills_fn="$1"
				;;
			--leader_fn )
				shift
				leader_fn="$1"
				;;
			--proj_fn )
				shift
				proj_fn="$1"
				;;
			--software_fn )
				shift
				software_fn="$1"
				;;
			-* )
				echo -e "Error: command line input ${red}$1${NC} is invalid" >&2 && return 1
		esac
		shift
	done
	
	# Check inputs
	[ -z "$label_fn" ] && label_fn=resume
	while [ -z "$out_dir" ]; do
		make_menu -c "$yellow" -p "Output directory for latex files?"
		read resp
		[ -z "$resp" ] && print_noInput && continue
		out_dir="$resp"
	done
	while [ -z "$class_fn" ]; do
		make_menu -c "$yellow" -p "Path to a latex class filename?"
		read resp
		[ -z "$resp" ] && print_noInput && continue
		[ ! -f "$resp" ] && echo -e "Error: $resp missing, try again" >&2 && continue
		class_fn="$resp"
	done
	while [ -z "$email" ]; do
		make_menu -c "$yellow" -p "Enter a valid email address:"
		read resp
		[ -z "$resp" ] && print_noInput && continue
		[ ! $(echo -e "$resp" | grep "@" | wc -l) -eq 1 ] \
			&& echo "Not a valid email, try again" >&2 && continue
		email="$resp"
	done
	while [ -z "$educate_fn" ]; do
		make_menu -c "$yellow" -p "Path to a latex filename with education?"
		read resp
		[ -z "$resp" ] && print_noInput && continue
		resp=$(echo -e $resp)
		[ ! -f "$resp" ] && echo -e "$resp missing" >&2 && continue
		educate_fn="$resp"
	done
	while [ -z "$exper_fn" ]; do
		make_menu -c "$yellow" -p "Path to a latex filename with experiences?"
		read resp
		[ -z "$resp" ] && print_noInput && continue
		[ ! -f "$resp" ] && echo -e "$resp missing" >&2 && continue
		exper_fn="$resp"
	done
	while [ -z "$name" ]; do
		make_menu -c "$yellow" -p "What is your name? (e.g. John Doe or Jane Doe, PhD)"
		read resp
		[ -z "$resp" ] && print_noInput && continue
		name="$resp"
	done
	
	# Make output directory and subfolders
	new_mkdir "$out_dir" "$out_dir/sections"
	
	# Process inputs
	class_fn=$(realpath $class_fn)
	[ ! $? -eq 0 ] && echo "Error running 'realpath' cmd" >&2 && return 1
	class_dir=$(echo $class_fn | sed 's|/|\n|g' | head -n -1 | tr '\n' '/' | sed 's|/$||')
	class_fn=$(echo $class_fn | sed 's|.cls$||' | sed 's|/|\n|g' | tail -n 1)
	email=$(echo $email | sed 's|_|\\_|g')
	[ ! -z "$objective_fn" ] 	&& [ ! -f "$objective_fn" ] && echo -e "$objective_fn missing" >&2 && return 1
	[ ! -z "$publish_fn" ] 		&& [ ! -f "$publish_fn" ] 	&& echo -e "$publish_fn missing" >&2 && return 1
	[ ! -z "$skills_fn" ] 		&& [ ! -f "$skills_fn" ] 		&& echo -e "$skills_fn missing" >&2 && return 1
	[ ! -z "$courses_fn" ] 		&& [ ! -f "$courses_fn" ] 	&& echo -e "$courses_fn missing" >&2 && return 1
	[ ! -z "$present_fn" ]		&& [ ! -f "$present_fn" ]		&& echo -e "$present_fn missing" >&2 && return 1
	[ ! -z "$leader_fn" ]			&& [ ! -f "$leader_fn" ]		&& echo -e "$leader_fn missing" >&2 && return 1
	[ ! -z "$proj_fn" ]				&& [ ! -f "$proj_fn" ]			&& echo -e "$proj_fn missing" >&2 && return 1
	[ ! -z "$accomplish_fn" ] && [ ! -f "$accomplish_fn" ] && echo -e "$accomplish_fn missing" >&2 && return 1
	[ ! -z "$software_fn" ] 	&& [ ! -f "$software_fn" ] 	&& echo -e "$software_fn missing" >&2 && return 1
	
	# Write resume.tex file
	res_fn="$out_dir/$label_fn.tex"
	new_rm "$res_fn"
	echo -e "\\documentclass[12pt]{$class_fn}\n" >> "$res_fn"
	echo -e "% Definitions" >> "$res_fn"
	echo -e "\\def\\MyName{$name}" >> "$res_fn"
	echo -e "\\def\\MyEmail{$email}" >> "$res_fn"
	[ ! -z "$phone" ]			&& echo -e "\\def\\MyPhone{$phone}" >> "$res_fn"
	[ ! -z "$location" ]	&& echo -e "\\def\\MyLocation{$location}" >> "$res_fn"
	[ ! -z "$github" ] 		&& echo -e "\\def\\MyGitHub{$github}" >> "$res_fn"
	[ ! -z "$linkedin" ] 	&& echo -e "\\def\\MyLinkedIn{$linkedin}" >> "$res_fn"
	[ ! -z "$position" ]	&& echo -e "\\def\\MyPosition{$position}" >> "$res_fn"
	[ ! -z "$orcid" ]			&& echo -e "\\def\\MyOrcid{$orcid}" >> "$res_fn"
	
	echo -e "\n\\\begin{document}\n" >> "$res_fn"
	
	# Objective/summary
	[ ! -z "$objective_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$objective_fn" "$out_dir/sections/objective.tex" \
		&& echo -e "\\input{sections/objective}\n" >> "$res_fn"
	# Skills
	[ ! -z "$skills_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$skills_fn" "$out_dir/sections/skills.tex" \
		&& echo -e "\\input{sections/skills}\n" >> "$res_fn"
	# Professional Experience
	let nAdd=nAdd+1 \
		&& cp "$exper_fn" "$out_dir/sections/experience.tex" \
		&& echo -e "\\input{sections/experience}\n" >> "$res_fn"
	# Education
	let nAdd=nAdd+1 \
		&& cp "$educate_fn" "$out_dir/sections/education.tex" \
		&& echo -e "\\input{sections/education}\n" >> "$res_fn"
	# Accomplishments
	[ ! -z "$accomplish_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$accomplish_fn" "$out_dir/sections/accomplishments.tex" \
		&& echo -e "\\input{sections/accomplishments}\n" >> "$res_fn"
	# Projects
	let nAdd=nAdd+1 \
		&& cp "$proj_fn" "$out_dir/sections/projects.tex" \
		&& echo -e "\\input{sections/projects}\n" >> "$res_fn"
	# Software
	[ ! -z "$software_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$software_fn" "$out_dir/sections/software.tex" \
		&& echo -e "\\input{sections/software}\n" >> "$res_fn"
	# Publications
	[ ! -z "$publish_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$publish_fn" "$out_dir/sections/publications.tex" \
		&& echo -e "\\input{sections/publications}\n" >> "$res_fn"
	# Courses
	[ ! -z "$courses_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$courses_fn" "$out_dir/sections/courses.tex" \
		&& echo -e "\\input{sections/courses}\n" >> "$res_fn"
	# Presentations
	[ ! -z "$present_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$present_fn" "$out_dir/sections/present.tex" \
		&& echo -e "\\input{sections/present}\n" >> "$res_fn"
	# Leadership
	[ ! -z "$leader_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$leader_fn" "$out_dir/sections/leadership.tex" \
		&& echo -e "\\input{sections/leadership}\n" >> "$res_fn"
	
	[ $nAdd -eq 0 ] \
		&& echo -e "Hi world\n" >> "$res_fn" \
		&& echo -e "Test run\n" >> "$res_fn"
	
	echo -e "\\\end{document}\n" >> "$res_fn"
	
	echo -e "${green}$label_fn.tex${NC} finalized." >&2
	
	# Run check of % usage in experience section
	n_pct=$(cat "$out_dir/sections/experience.tex" | grep -v "^%" \
		| sed 's|\\%|pct|g' | grep "%" | wc -l)
	[ $n_pct -gt 0 ] && echo -e "${yellow}Warning${NC}: Detected use of non-leading char '%' within latex, double check tex experience.tex!" >&2 && return 1
	
	# Check incomplete sections
	for keyw in "hfill somewhere" "hfill MMM YYYY"; do
		n_miss=$(cat "$out_dir/sections/experience.tex" | grep -v "^%" \
			| grep "$keyw" | wc -l)
		[ $n_miss -gt 0 ] && echo -e "${yellow}Warning${NC}: Detected incomplete entries (${cyan}${keyw}${NC}) within latex, double check tex experience.tex!" >&2 && return 1
	done
	
	if [ $compile -eq 1 ]; then
		echo -e "${yellow}Executing latexmk ...${NC}" >&2
		
		export TEXINPUTS="$class_dir"
		cleanup_tex -o "$out_dir"
		cmd="latexmk"
		cmd="$cmd -cd" # change directory to source tex file when processing
		cmd="$cmd -output-format=pdf"
		cmd="$cmd \"$res_fn\""
		
		# echo -e "cmd = $cmd" >&2
		eval $cmd >&2 # > /dev/null
		[ ! $? -eq 0 ] && echo "Error in latexmk" >&2 && return 1
		
		cleanup_tex -o "$out_dir"
		# new_rm "$out_dir/sections"
		[ ! -z "$TEXINPUTS" ] && unset TEXINPUTS
		echo -e "PDF located at ${yellow}$out_dir${NC}/${green}$label_fn.pdf${NC}" >&2
		
	fi
	
	return 0
	
}

srcPL_resume=1

## EOF


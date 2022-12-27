#!/bin/sh

[ ! -z "$srcPL_resume" ] && [ $srcPL_resume -eq 1 ] && return 0
[ -z "$git_dir" ] && git_dir=$(cd $(dirname $BASH_SOURCE)/../..; pwd)

# ----------
# Get baSHic
# ----------
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

# ----------
# Get firstClass
# ----------
repo=firstClass
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

# ----------
# Reset
# ----------
unset repo repo_dir

# ----------
# Check latexmk is on PATH
# ----------
[ -z "$chk_latexmk" ] \
	&& chk_latexmk=$(which latexmk &> /dev/null; echo $?)
[ ! $chk_latexmk -eq 0 ] \
	&& echo "latexmk command not found" >&2 \
	&& return 1

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
	local educate_fn exper_fn objective_fn publish_fn 
	local skills_fn courses_fn
	local resp cmd compile nAdd
	
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
			--publish_fn )
				shift
				publish_fn="$1"
				;;
			--skills_fn )
				shift
				skills_fn="$1"
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
	
	[ ! -z "$objective_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$objective_fn" "$out_dir/sections/objective.tex" \
		&& echo -e "\\input{sections/objective}\n" >> "$res_fn"
	[ ! -z "$skills_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$skills_fn" "$out_dir/sections/skills.tex" \
		&& echo -e "\\input{sections/skills}\n" >> "$res_fn"
	let nAdd=nAdd+1 \
		&& cp "$exper_fn" "$out_dir/sections/experience.tex" \
		&& echo -e "\\input{sections/experience}\n" >> "$res_fn"
	let nAdd=nAdd+1 \
		&& cp "$educate_fn" "$out_dir/sections/education.tex" \
		&& echo -e "\\input{sections/education}\n" >> "$res_fn"
	[ ! -z "$publish_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$publish_fn" "$out_dir/sections/publications.tex" \
		&& echo -e "\\input{sections/publications}\n" >> "$res_fn"
	[ ! -z "$courses_fn" ] \
		&& let nAdd=nAdd+1 \
		&& cp "$courses_fn" "$out_dir/sections/courses.tex" \
		&& echo -e "\\input{sections/courses}\n" >> "$res_fn"
	
	[ $nAdd -eq 0 ] \
		&& echo -e "Hi world\n" >> "$res_fn" \
		&& echo -e "Test run\n" >> "$res_fn"
	
	echo -e "\\\end{document}\n" >> "$res_fn"
	
	echo -e "${green}$label_fn.tex${NC} finalized." >&2
	
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
		new_rm "$out_dir/sections"
		[ ! -z "$TEXINPUTS" ] && unset TEXINPUTS
		echo -e "PDF located at ${yellow}$out_dir${NC}/${green}$label_fn.pdf${NC}" >&2
		
	fi
	
	return 0
	
}

srcPL_resume=1

## EOF


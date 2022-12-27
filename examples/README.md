# Examples

## Table of Contents

* [Industry Resume](#industry-resume)
* [Beamer Slides](#beamer-slides)

## Industry Resume

<details>
<summary>Click to expand!</summary>

* Input tex files are under the current directory
* Dependencies: TexLive (MikTeX) aka software containing 
	`pdflatex` or `latexmk`
* Execution

In your favorite linux terminal, navigate to `firstClass` 
directory. Run the following script/steps.

```Shell
# Source bash script
. scripts/make_resume.sh
[ ! $? -eq 0 ] && echo "Error src-ing make_resume.sh" >&2 \
	&& return 1

# Set some inputs
repo_dir="$git_dir/firstClass"
tmp_dir="$repo_dir/examples"

# customize this variable if you like
out_dir="$HOME/Downloads"
[ ! -d "$out_dir" ] && mkdir "$out_dir"

# Compile contents
make_resumeTex \
	--compile \
	-o "$out_dir/myresume" \
	--name "FirstName LastName, PhD" \
	--email abc@def.com \
	--github username \
	--location "City, State" \
	--position "Job Position" \
	--phone 123-456-7890 \
	--linkedin username \
	--orcid 0000-0000-0000-0000 \
	--class_fn "$repo_dir/files/resume.cls" \
	--educate_fn "$tmp_dir/education.tex" \
	--exper_fn "$tmp_dir/experience.tex" \
	--objective_fn "$tmp_dir/objective.tex" \
	--publish_fn "$tmp_dir/publications.tex" \
	--skills_fn "$tmp_dir/skills.tex" \
	--courses_fn "$tmp_dir/courses.tex"

[ ! $? -eq 0 ] && echo "Error in make_resumeTex" >&2 \
	&& return 1

```

</details>

## Beamer Slides

Incomplete

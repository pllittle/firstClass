# Examples

## Industry Resume

* Input tex files are under the current directory
* Dependencies: TexLive (MikTeX) aka software containing 
	`pdflatex` or `latexmk`
* Execution

In your favorite terminal, navigate to `firstClass` 
directory. Run the following script/steps.

```Shell
# Source bash script
. make_resume.sh

# Set some inputs
repo_dir="$git_dir/firstClass"
tmp_dir="$repo_dir/examples"
desk_dir="$HOME/Desktop"

# Compile contents
make_resumeTex \
	--compile \
	-o "$desk_dir/myresume" \
	--name "FirstName LastName, PhD" \
	--email abc@def.com \
	--github username \
	--location "City, State" \
	--position "Job Position" \
	--phone 123-456-7890 \
	--linkedin username \
	--orcid 0000-0002-9789-8501 \
	--class_fn "$repo_dir/files/resume.cls" \
	--educate_fn "$tmp_dir/education.tex" \
	--exper_fn "$tmp_dir/experience.tex" \
	--objective_fn "$tmp_dir/objective.tex" \
	--publish_fn "$tmp_dir/publications.tex" \
	--skills_fn "$tmp_dir/skills.tex" \
	--courses_fn "$tmp_dir/courses.tex"

```

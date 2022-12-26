% My first class file

% ##################################
% Required: current latex version, case-sensitive
\NeedsTeXFormat{LaTeX2e} 

% Required: match class name
\ProvidesClass{first_class}[2022/12/24 Test Class]

% Required: Load existing Latex class
\LoadClass[10pt]{article}

% ##################################
% Load packages in class file
% Page layout
\RequirePackage[margin=0.5in,bottom=1.5in]{geometry}
% Dummy texts
\RequirePackage{lipsum}
% Font used
\RequirePackage[T1]{fontenc} %  Font encoding https://texfaq.org/FAQ-why-inp-font
\RequirePackage[default,semibold]{sourcesanspro}
% Left indent
\raggedright
% COLOR
\RequirePackage{soul}
\RequirePackage{xcolor}
\definecolor{highlight}{RGB}{14,125,156} % pick color https://g.co/kgs/aoqdi7
\definecolor{orcid}{RGB}{166,206,57}
\definecolor{linkedin}{RGB}{0,114,177}
\definecolor{github}{RGB}{157,69,170}
% LINKS
\RequirePackage{hyperref}
\hypersetup{colorlinks=true,urlcolor=highlight}
% Fancy Icons
\RequirePackage{fontawesome5}
% Helps with rerun compiling warnings
% \RequirePackage{bookmark}
% Bullet points
%\RequirePackage[inline]{enumitem}
\setlength{\tabcolsep}{0in}

% ##################################
% Make resume header
\RequirePackage{fancyhdr}
\fancyhf{} % clear existing header/footer entries
\pagestyle{fancy}

% Left Header
\lhead{
\textbf{Contact Info}
\ifx \MyPhone \undefined \\ \hl{PhoneNum} \else \\ {\color{green}\faIcon{phone-square-alt}} \MyPhone\fi
\ifx \MyLocation \undefined \\ \hl{City, State} \else \\ {\color{red}\faIcon{map-marker-alt}} \MyLocation\fi
\ifx \MyEmail \undefined \\ \hl{abc\_def@ghi.com} \else \\ {\color{cyan}\faIcon{at}} \href{mailto:\MyEmail}{\MyEmail}\fi}

% Center Header
\chead{
\Huge{\ifx \MyName \undefined \hl{My Name} \else \MyName\fi} \\
\vspace{0em} % some spacing below name
\Large{\ifx \MyPosition \undefined \hl{Position} \else \MyPosition\fi}}

% Right Header
\rhead{
\faIcon{briefcase} \textbf{Portfolio}
\ifx \MyGitHub \undefined \else \\ {\color{github}\faIcon{github}} \href{https://github.com/\MyGitHub}{github.com/\MyGitHub}\fi
\ifx \MyLinkedIn \undefined \else \\ {\color{linkedin}\faIcon{linkedin}} \href{https://www.linkedin.com/in/\MyLinkedIn}{linkedin.com/in/\MyLinkedIn}\fi
\ifx \MyOrcid \undefined \else \\ {\color{orcid}\faIcon{orcid}} \href{https://orcid.org/\MyOrcid}{orcid.org/\MyOrcid}\fi}

% Spacing from top of page to header content
\setlength{\headheight}{80pt}

% width of line below header
\renewcommand{\headrulewidth}{1pt}

% spacing from \headrule to content below
\setlength{\headsep}{15pt}

% ##################################
% Section formatting
\RequirePackage{titlesec}
\titlespacing*{\section}
	{0em} % spacing to the left
	{0.5em} % spacing above
	{0em} % spacing below
\titleformat{\section}
	{\color{highlight} \scshape \raggedright \large} % formatting: color, alignment, size, capitalization, etc
	{} % label: Used to prefix section e.g. the section/title number or no label
	{0em} % separation: between label and section title
	{} % before-code: place text, spacing, lines after label and b4 title etc.
	[\vspace{-0.75em}\hrulefill] % after-code: place text, spacing, lines after title
% Subsection formatting
\titlespacing*{\subsection}
	{0em} % spacing to the left
	{0em}	% spacing above
	{0em} % spacing below
\titleformat{\subsection}
	{\bfseries} % formatting:
	{} % label:
	{0em} % separation:
	{} % before-code: 
	[] % after-code:



% ##################################
% Education Style
\newcommand{\educ}[4]{
\ifx&#1& {\bfseries \hl{Degree in Department}}\else {\bfseries #1}\fi,
\ifx&#2& \textit{\hl{Institution}}\else \textit{#2}\fi
\hfill
\ifx&#3& \hl{Month} \else #3 \fi
\ifx&#4& \hl{Year}\else #4\fi}

% ##################################
% Skills Style
\newcommand{\skills}[1]{{\bfseries #1}}

% ##################################
% Subtext
\newcommand{\subtext}[1]{\textit{#1}\par\vspace{-.75em}}

% ##################################
% Itemize setup
%\setlist[itemize]{align=parleft,left=0pt..1em}
\newenvironment{zitemize}{
\begin{itemize}
\itemsep 0pt 
\parskip 0pt
\parsep 1pt
\itemindent -5pt}
{\end{itemize}\vspace{-.5em}}

\newenvironment{zenumerate}{
\begin{enumerate}
\itemsep 0pt 
\parskip 0pt
\parsep 1pt
\itemindent -5pt}
{\end{enumerate}\vspace{-.5em}}

% NO PAGE NUMBER
\pagenumbering{gobble}

% SUBFILES IMPORTING
\RequirePackage{standalone}

%% EOF

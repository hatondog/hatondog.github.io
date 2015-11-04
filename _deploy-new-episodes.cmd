:: Run episodes build script
ruby _build-episodes.rb

:: Add only new episodes
(echo a&echo *&echo q)|git add _episodes -i

:: Commit new episodes
git commit -m ":computer: Auto-adding new episode"

:: Push to GitHub
git push
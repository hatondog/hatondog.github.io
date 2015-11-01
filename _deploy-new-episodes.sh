:: Run episodes build script
ruby _build-episodes.rb

:: Add only new episodes
git add $(git ls-files _episodes -o --exclude-standard)

:: Commit new episodes
git commit -m ":computer: Auto-adding new episode"

:: Push to GitHub
git push
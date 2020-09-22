git branch -m master main
git push azuredevops :master main
git push origin :master main
git fetch --all
git branch -u azuredevops/main main
git branch -u origin/main main
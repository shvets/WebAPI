1. Create Specs repository on github


2. Add repository locally:

pod repo add yaga-specs git@github.com:shvets/Specs.git

3. Test:

cd ~/.cocoapods/repos/yaga-specs
pod repo lint .

4. In pod project:

- make modifications, commit it

git add . -m ""
git push

- create tag, update tags in remote repository

git tag 1.0.0
git push --tags

- push your pod:

pod repo push --allow-warnings yaga-specs AudioPlayer.podspec


5. In project that uses pod:

- update version of dependent pod

- run command:

pod install --repo-update


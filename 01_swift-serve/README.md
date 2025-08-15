# Swift Serve

This example started from a direct copy of https://github.com/adam-fowler/swift-web on 2025, Aug 15. 

He provides instruction on how to install it using [mint](https://github.com/yonaskolb/Mint), which is a great tool. Use it. I am going to explain first how to use it without installing it, and then how to install it by hand. 

I changed the name to be more inline with what I type in other languages. 

## While still testing

```shell
# from the directory with this readme
cd swift-serve
swift run swift-serve ../public
```

## Once mostly satisfied

One of the advantages of using `mint` is it handles where to put and where to find all the compiled binaries really nicely. 

But in case you want to do something on your own, let say you wanted to start keeping all your hand written CLI's in a folder called `~/mybin`

I want to use the debug version of the code so I am not going to recompile in release version (`swift build --configuration release`).

Next am going to copy the executable, not symlink it (`ln -s /path/to/original /path/to/link`) which would also be an option if you wanted it to stay up to date as you developed. 

```shell
## make the folder
mkdir ~/mybin
## From Directory with this readme, after having run `swift build` at the very least. 
cd swift-serve/.build/debug
cp swift-serve ~/mybin/swift-serve
cd -
cd public
~/mybin/swift-serve
```

This should run the server.  If you'd like to add the ~/mybin to the PATH

```zsh
# see all the folders in your path
echo $PATH 
## then either add it to the beginning to search it first
PATH=~/mybin:$PATH
## OR add it to the end to search it last. 
PATH=$PATH:~/mybin
## check your path again
echo $PATH
```

This will ONLY work for THIS shell. To update your profile try seeing what you currently have, e.g. `cat ~/.zprofile` if using zsh or `ls -al ~/` to go hunting.

Add something like 

```
if [[ ":$PATH:" != *":~/mybin:"* ]]; then
    export PATH="Users/$USER/mybin:$PATH"
fi
```
at the bottom of the file to add your custom folder at the front of the PATH's line. 
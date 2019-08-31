### Git操作
- git clone 项目地址                            将远程项目拉到本地
- git add 文件                                  添加文件到暂存区
- git commit -m '提交信息'                      将暂存区提交到本地仓库
    在使用git commit命令之前，通过使用git add对索引进行递增的“添加”更改(注意：修改后的文件的状态必须为“added”);
    通过使用git rm从工作树和索引中删除文件，再次使用git commit命令;
    通过将文件作为参数列出到git commit命令(不使用--interactive或--patch选项)，在这种情况下，提交将忽略索引中分段的更改，而是记录列出的文件的当前内容(必须已知到Git的内容) ;
    通过使用带有-a选项的git commit命令来自动从所有已知文件(即所有已经在索引中列出的文件)中添加“更改”，并自动从已从工作树中删除索引中的“rm”文件 ，然后执行实际提交;
    通过使用--interactive或--patch选项与git commit命令一起确定除了索引中的内容之外哪些文件或hunks应该是提交的一部分，然后才能完成操作。


- git push                                      将本地仓库推送到远程仓库
- git status                                    命令用于显示工作目录和暂存区的状态
- git tag                                       命令用于创建，列出，删除或验证使用GPG签名的标签对象
    git tag -a v1.4 -m 'my version 1.4'
    默认情况下，git push 并不会把标签传送到远端服务器上，
    只有通过显式命令才能分享标签到远端仓库。其命令格式如同推送分支，
    运行 git push origin [tagname] 即可：
    $ git push origin v1.5


In this repository you can find many PowerShell scripts which were written by me. Each script are independent from one another and each script written for a reason. You can freely choose the script which will work for you.
Here is the description of each script:

Task1.ps1 -> With this script you can display all users in your Active Directory. You can add and remove users and change their mail address. Note: you should login with an account which has the permissions to do the tasks. Also take a look at the comments inside the script, so that it will work seamlessly.

Task2.ps1 -> With this script you can store the information of newly created user to a file, all information of the user are hashed with SHA256. You can also check if a user exist by typing its sAMAccount name and password. The script will not let you create a new user if the sAMAccount name already exists in the file.

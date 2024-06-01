### About
These are very simple powershell scripts to kickstart your django project.


`./raw_django.ps1 <working_dir>`: Just builds a standard Django app.

`./user_model.ps1 <working_dir>`: Generates a user model with your standard Django app which relies on an email and password for authentication instead of a usename and password.

`./user_template_api.ps1 <working_dir>`: Generates a user model with templates, static styling, and APIs for logins, logouts, listing users, and fetching user details.
 
`./drf-user_model.ps1 <working_dir>`: Generates a user model and a back-end API with Django REST Framework for creating users and logging in. 


### Instructions:

1. Open PowerShell with administrator privileges and run the following command:
     ```powershell
     Set-ExecutionPolicy RemoteSigned
     ```

2. Choose the script you want to run based on your project requirements. For example:
     ```powershell
     .\raw_django.ps1 example-directory
     ```
     ```powershell
     .\user_model.ps1 C:\Projects\existing-django-project
     ```
     ```powershell
     .\user_template_api.ps1 .
     ```
     ```powershell
     .\drf-user_model.ps1 C:\Projects\MyDjangoProject
     ```
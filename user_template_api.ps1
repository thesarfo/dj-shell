$working_dir = $args[0]

New-Item $working_dir -ItemType Directory -ea 0
Set-Location $working_dir

python -m venv .\venv
.\venv\Scripts\Activate.ps1

@'
Django>=5.0.2
'@ | Out-File -FilePath .\requirements.txt -Encoding utf8

pip install -r requirements.txt
django-admin startproject config .

# User Model
python manage.py startapp users
@'
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.db import models
from django.urls import reverse
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

from .managers import ApplicationUserManager


class ApplicationUser(AbstractBaseUser, PermissionsMixin):
    class Meta:
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    email = models.EmailField(_('email address'), unique=True)
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    date_joined = models.DateTimeField(default=timezone.now)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    objects = ApplicationUserManager()

    def __str__(self):
        return self.email

    def get_absolute_url(self):
        return reverse('user_detail', kwargs={'pk': self.pk})
'@ | Out-File -FilePath .\users\models.py -Encoding utf8

@'
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/5.0/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-qt-sq3+6fm!)qcmxyugofjyz_0dn8p7ej$h^j=quntuw!4(x2-'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'users',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'


# Database
# https://docs.djangoproject.com/en/5.0/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_USER_MODEL = 'users.ApplicationUser'

LOGIN_REDIRECT_URL = '/users/'
LOGOUT_REDIRECT_URL = '/users/'


# Password validation
# https://docs.djangoproject.com/en/5.0/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/5.0/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.0/howto/static-files/

STATIC_URL = 'static/'
STATICFILES_DIRS = [BASE_DIR / 'static']

# Default primary key field type
# https://docs.djangoproject.com/en/5.0/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
'@ | Out-File -FilePath .\config\settings.py -Encoding utf8

@'
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .forms import ApplicationUserCreationForm, ApplicationUserChangeForm
from .models import ApplicationUser


@admin.register(ApplicationUser)
class ApplicationUserAdmin(UserAdmin):
    add_form = ApplicationUserCreationForm
    form = ApplicationUserChangeForm
    model = ApplicationUser
    list_display = ('email', 'is_staff', 'is_active',)
    list_filter = ('email', 'is_staff', 'is_active',)
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Permissions', {'fields': ('is_staff', 'is_active', 'groups', 'user_permissions')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': (
                'email', 'password1', 'password2', 'is_staff',
                'is_active', 'groups', 'user_permissions'
            )}
        ),
    )
    search_fields = ('email',)
    ordering = ('email',)
'@ | Out-File -FilePath .\users\admin.py -Encoding utf8

@'
from django.contrib.auth.forms import UserCreationForm, UserChangeForm

from .models import ApplicationUser


class ApplicationUserCreationForm(UserCreationForm):

    class Meta:
        model = ApplicationUser
        fields = ('email',)


class ApplicationUserChangeForm(UserChangeForm):

    class Meta:
        model = ApplicationUser
        fields = ('email',)
'@ | Out-File -FilePath .\users\forms.py -Encoding utf8

@'
from django.contrib.auth.base_user import BaseUserManager
from django.utils.translation import gettext_lazy as _


class ApplicationUserManager(BaseUserManager):
    '''
    Custom user model manager where email is the unique identifiers
    for authentication instead of usernames.
    '''
    def create_user(self, email, password, **extra_fields):
        '''
        Create and save a user with the given email and password.
        '''
        if not email:
            raise ValueError(_('The Email must be set'))
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save()
        return user

    def create_superuser(self, email, password, **extra_fields):
        '''
        Create and save a SuperUser with the given email and password.
        '''
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))
        return self.create_user(email, password, **extra_fields)
'@ | Out-File -FilePath .\users\managers.py -Encoding utf8

Write-Output 'Migrations are coming...'

python manage.py makemigrations
python manage.py migrate

# User API + Template
@'
from django.contrib import admin
from django.urls import path, include


urlpatterns = [
    path('admin/', admin.site.urls),
    path('users/', include('users.urls')),
]
'@ | Out-File -FilePath .\config\urls.py -Encoding utf8

@'
from . import views
from django.urls import path, include

urlpatterns = [
    path('', views.UserList.as_view(), name='home'),
    path('<int:pk>/', views.UserDetail.as_view(), name='user_detail'),
    path('create/', views.UserCreate.as_view(), name='user_create'),
    path('login/', views.UserLogin.as_view(), name='user_login'),
    path('logout/', views.UserLogout.as_view(), name='user_logout'),
]
'@ | Out-File -FilePath .\users\urls.py -Encoding utf8

@'
from django import urls
from django.contrib.auth import views, login as auth_login
from django.views import generic

from .models import ApplicationUser as User


# Create your views here.
class UserList(generic.ListView):
    queryset = User.objects.all()
    template_name = 'index.html'
    context_object_name = 'user_list'


class UserDetail(generic.DetailView):
    model = User
    template_name = 'profile.html'


class UserCreate(generic.CreateView):
    model = User
    template_name = 'create.html'
    fields = ('email', 'password')


class UserLogin(views.LoginView):
    template_name = 'login.html'


class UserLogout(views.LogoutView):
    pass
'@ | Out-File -FilePath .\users\views.py -Encoding utf8

Set-Location -Path 'users'
New-Item 'templates' -ItemType Directory -ea 0
Set-Location -Path '..'

@'
<!DOCTYPE html>
<html>

<head>
    <title>codewriter3000's Django Boilerplate</title>
    <link href='https://fonts.googleapis.com/css2?family=Raleway:wght@300&display=swap' rel='stylesheet'/>
    <meta name='google' content='notranslate'/>
    <meta name='viewport' content='width=device-width, initial-scale=1'/>
    <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css'
          integrity='sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm'
          crossorigin='anonymous'/>
</head>

<body class='bg-dark'>
<style>
    body {
        font-family: 'Raleway', sans-serif;
        font-size: 17px;
    {#background-color: #333333;#}
    }

    .shadow {
        box-shadow: 0 4px 2px -2px rgba(0, 0, 0, 0.1);
    }

    .masthead {
        height: auto;
        padding-bottom: 15px;
        box-shadow: 0 16px 48px #303030;
        padding-top: 10px;
    }

    .logoutButton {
        background-color: inherit;
        color: inherit;
        border: inherit;
    }

    .logoutButton:hover {
        cursor: pointer;
    }
</style>

<!-- Navigation -->
<nav class='navbar navbar-expand-lg navbar-dark bg-dark shadow' id='mainNav'>
    <div class='container-fluid'>
        <a class='navbar-brand' href='{% url 'home' %}'>codewriter3000's Django Boilerplate</a>
        <button class='navbar-toggler navbar-toggler-right' type='button' data-toggle='collapse'
                data-target='#navbarResponsive'
                aria-controls='navbarResponsive' aria-expanded='false' aria-label='Toggle navigation'>
            <span class='navbar-toggler-icon'></span>
        </button>
        <div class='collapse navbar-collapse' id='navbarResponsive'>
            <ul class='navbar-nav ml-auto'>
                {% if user.is_authenticated %}
                    <li class='nav-item text-black'>
                        <a class='nav-link text-black font-weight-bold'
                           href='{% url 'user_detail' user.id %}'>My Profile</a>
                    </li>
                    <li class='nav-item text-black'>
                        <form id='logout-form' method='post' action='{% url 'user_logout' %}'>
                            {% csrf_token %}
                            <button class='nav-link text-black font-weight-bold logoutButton' type='submit'>Logout</button>
                        </form>
                    </li>
                {% else %}
                    <li class='nav-item text-black'>
                        <a class='nav-link text-black font-weight-bold'
                           href='{% url 'user_login' %}'>Login</a>
                    </li>
                {% endif %}
                    <a class='nav-link text-black font-weight-bold'
                       target='_blank'
                       href='https://www.github.com/codewriter3000/django-boilerplate'>GitHub Repo</a>
                </li>
            </ul>
        </div>
    </div>
</nav>
{% block content %}
    <!-- Content Goes here -->
{% endblock content %}
<!-- Footer -->
<footer class='py-3 bg-grey'>
    <p class='m-0 text-light text-center '>Copyright &copy; codewriter3000</p>
</footer>
</body>
</html>
'@ | Out-File -FilePath .\users\templates\base.html -Encoding utf8

@'
{% extends 'base.html' %}
{% block content %}
    <form method='post'>{% csrf_token %}
        {{ form.as_p }}
        <input type='submit' value='Save'>
    </form>
{% endblock %}
'@ | Out-File -FilePath .\users\templates\create.html -Encoding utf8

@'
{% extends 'base.html' %}
{% block content %}
    <style>
        body {
            font-family: 'Raleway', sans-serif;
            font-size: 18px;
        }

        .head_text {
            color: #313131;
        }

        .card {
            box-shadow: 0 16px 48px #33373B;
        }
    </style>

    <header class='masthead bg-primary'>
        <div class='overlay'></div>
        <div class='container'>
            <div class='row'>
                <div class='col-md-8 col-md-10 mx-auto'>
                    <div class='site-heading'>
                        <h3 class='site-heading my-4 mt-3 text-white'>User List</h3>
                    </div>
                </div>
            </div>
        </div>
    </header>
    <div class='container'>
        <div class='row'>
            <!-- Blog Entries Column -->
            <div class='col-md-8 mt-3 left'>
                {% for app_user in user_list %}
                    <div class='card mb-4 bg-dark text-light'>
                        <div class='card-body'>
                            <h4 class='card-title'>{{ app_user.email }}
                                {% if app_user.is_staff %}
                                    <span class='badge badge-warning'>Staff</span>
                                {% endif %}
                                {% if not app_user.is_active %}
                                    <span class='badge badge-danger'>Inactive</span>
                                {% endif %}
                            </h4>
                            <p>
                                {% if app_user.is_active %}
                                    <a href='{% url 'user_detail' app_user.id %}' class='btn btn-primary'>View Profile</a>
                                {% endif %}
                            </p>
                        </div>
                    </div>
                {% endfor %}
            </div>
            {% block sidebar %} {% include 'sidebar.html' %} {% endblock sidebar %}
        </div>
    </div>
{% endblock %}
'@ | Out-File -FilePath .\users\templates\index.html -Encoding utf8

@'
{% extends 'base.html' %}
{% block content %}
    <header class='masthead bg-primary'>
        <div class='overlay'></div>
        <div class='container'>
            <div class='row'>
                <div class='col-md-8 col-md-10 mx-auto'>
                    <div class='site-heading'>
                        <h3 class='site-heading my-4 mt-3 text-white'>Login</h3>
                    </div>
                </div>
            </div>
        </div>
    </header>
    <div class='container'>
        <div class='col-md-8 mt-3 left'>
            <div class='card mb-4 bg-dark text-light'>
                <div class='card-body'>
                    <form method='post'>{% csrf_token %}
                        {{ form.as_p }}
                        <button class='btn btn-primary' type='submit'>Login</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
{% endblock %}
'@ | Out-File -FilePath .\users\templates\login.html -Encoding utf8

@'
{% extends 'base.html' %} {% block content %}

    <div class='container'>
        <div class='row'>
            <div class='col-md-8 card mb-4 mt-3 left top bg-dark text-light'>
                <div class='card-body'>
                    <h4 class='card-title'>{{ object.email }}
                        {% if object.is_staff %}
                            <span class='badge badge-warning'>Staff</span>
                        {% endif %}
                    </h4>
                </div>
            </div>
            {% block sidebar %} {% include 'sidebar.html' %} {% endblock sidebar %}
        </div>
    </div>

{% endblock content %}
'@ | Out-File -FilePath .\users\templates\profile.html -Encoding utf8

@'
{% block sidebar %}

<style>
        .card{
            box-shadow: 0 16px 48px #303030;
        }

</style>

<!-- Sidebar Widgets Column -->
<div class='col-md-4 float-right '>
<div class='card my-4 bg-dark text-light'>
        <h5 class='card-header'>Credits</h5>
    <div class='card-body'>
        <p class='card-text'>I made this boilerplate template from these guys right here, so give them some credit too.</p>
        <a target='_blank' href='https://djangocentral.com/building-a-blog-application-with-django'
           class='btn btn-primary'>Django Central</a>
    </div>
</div>
</div>

{% endblock sidebar %}
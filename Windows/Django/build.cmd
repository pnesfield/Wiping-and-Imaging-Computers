python --version
pip install Django
mkdir Imaging
django-admin startproject project Imaging
cd Imaging
django-admin startapp Webapp
python manage.py migrate
copy /Y C:\Users\user1\Documents\philn\Dev\django\urls.py project\
copy /Y C:\Users\user1\Documents\philn\Dev\django\settings.py project\
copy /Y C:\Users\user1\Documents\philn\Dev\django\views.py Webapp\
mkdir Assets
mkdir Serials
python manage.py check
python manage.py runserver 0.0.0.0:8000
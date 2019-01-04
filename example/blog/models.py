# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.conf import settings
from django.db import models

# Create your models here.


class Post(models.Model):

    title = models.CharField(max_length=64)
    author = models.ForeignKey(settings.AUTH_USER_MODEL)

    content = models.TextField()


class Comment(models.Model):

    post = models.ForeignKey(Post)
    author = models.ForeignKey(settings.AUTH_USER_MODEL)

    content = models.TextField()

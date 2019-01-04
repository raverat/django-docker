# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib.auth import get_user_model
from django.test import TransactionTestCase

from .models import Post

User = get_user_model()


class PostTestCase(TransactionTestCase):

    def setUp(self):
        self.test_user = User.objects.create_user('testuser', 'testuser@email.com', 'password')

    def test_create(self):
        post = Post.objects.create(title='My Awesome Post', author=self.test_user, content='My Awesome Post Content')
        self.assertEqual(post.title, 'My Awesome Post')
        self.assertEqual(post.author, self.test_user)
        self.assertEqual(post.content, 'My Awesome Post Content')

# Generated by Django 5.1.4 on 2025-01-24 00:38

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('schedule', '0005_alter_courseassignment_course_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='courseassignment',
            name='course',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='schedule.course'),
        ),
    ]

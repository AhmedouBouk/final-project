# Generated by Django 5.1.4 on 2025-01-25 14:08

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('schedule', '0008_courseassignment_description_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='courseassignment',
            name='course',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to='schedule.course'),
        ),
    ]

{%- from "mongodb/map.jinja" import client with context %}
{%- if client.get('enabled', True) %}

mongodb_client_packages:
  pkg.installed:
  - names: {{ client.pkgs }}

{%- for user_name, user in client.get('user', {}).iteritems() %}

{%- if client.server is defined %}
{% set mongo_host = client.server.get('host') %}
{% set mongo_port = client.server.get('port') %}
{%- else %}
{% set mongo_host = 'localhost' %}
{% set mongo_port = '27017' %}
{%- endif %}

{%- if user.get('enabled', True) %}
{% set state = 'present' %}
{%- else %}
{% set state = 'absent' %}
{%- endif %}

mongo_user_{{ user_name }}_{{ state }}:
  mongodb_user.{{ state }}:
    - name: {{ user_name }}
    {%- if state == 'present' %}
    - passwd: {{ user.get('passwd', 'password') }}
    {%- endif %}
    {%- if user.database is defined and user.database.get('enabled', true) %}
    - database: {{ user.database.get('name') }}
    {%- endif %}
    {%- if client.admin is defined %}
    - user: {{ client.admin.get('user') }}
    - password: {{ client.admin.get('password') }}
    {%- endif %}
    - host: {{ mongo_host }}
    - port: {{ mongo_port }}

{%- if user.database is defined and user.database.get('enabled', true) == false %}
mongo_db_{{  user.database.get('name') }}_absent:
  mongodb_database.absent:
    - name: user.database.get('name')
    {%- if client.admin is defined %}
    - user: {{ client.admin.get('user') }}
    - password: {{ client.admin.get('password') }}
    {%- endif %}
    - host: {{ mongo_host }}
    - port: {{ mongo_port }}
{%- endif %}

{%- endfor %}

{%- endif %}
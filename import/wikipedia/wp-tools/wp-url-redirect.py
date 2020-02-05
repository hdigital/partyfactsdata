# run in Django shell -- `python manage.py shell`
import requests

from poldata.data.models import Party

parties = Party.objects.exclude(wikipedia__isnull=True).exclude(wikipedia__exact='')
for party in parties:
    r = requests.get(party.wikipedia)
    if ((party.wikipedia != r.url) & (len(r.url) < 200)):
        print(party.wikipedia, r.url)
        party.wikipedia = r.url
        party.save_user()

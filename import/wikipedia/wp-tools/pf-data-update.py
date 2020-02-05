from poldata.data.models import Link

YEAR_DISSOLVED_MIN = '2005'

wp_links = Link.objects.filter(party_all__dataset__key = 'wikipedia')

for li in wp_links:
    wp_year_dissolved = li.party_all.data.get('year_dissolved')
    if wp_year_dissolved and li.party.year_last is None:
        if wp_year_dissolved >= YEAR_DISSOLVED_MIN:
            print('pf_id:', li.party.id, 'last year', wp_year_dissolved)
            li.party.year_last = wp_year_dissolved
            li.party.save_user()

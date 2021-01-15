# README

## Mapping alma marc fields to solr indexed fields

| Alma MARC field<br>[tag:code] | Description | SOLR field |
| --- | --- | --- |
| tag=001, code=n/a | ID of record in alma. Currently saved as a single valued string in SOLR. | ID |
| tag=n/a, code=n/a | Inserts full marc record as XML in SOLR. Currently saved as a single valued text in SOLR. | marc_display_tesi |
| tag=100-900, code= any | Any tag from 100 to 900 with any code in the marc record is saved in the text field SOLR (these fields are meant to be searhable and are insert into the text field). Currently saved as a single valued text in SOLR. | text_tesi |
| <ul><li>tag=008[35-37]</li><li>tag=041, code=a</li><li>tag=041, code=d</li></ul> | <ul><li>Characters at positions from 35 to 37 for tag 008</li><li>tag 041 with code `a`</li><li>tag 041 with code `d`</li></ul>Above fields from a marc record are used to map languauge facet for the record in SOLR. Currently saved as multi-valued strings in SOLR. | language_facet_tesim |
| <ul><li>tag=000[6-7]</li><li>tag=000[6]</li></ul> | <ul><li>Characters at position 6 and 7 for tag 000 (this could be leader in marc record)</li><li>Character at 6th position for tag 000 (this could be leader in marc record)</li></ul>Above fields from a marc record are used to map format for the record in SOLR. Currently saved as multi-valued strings in SOLR. | format_tesi |
| <ul><li>tag=007[0-1]</li><li>tag=007[0]</li></ul> | <ul><li>Characters at position 0 and 1 for tag 007</li><li>Characters at position 0 for tag 007</li></ul> Above fields from a marc record are used to map format for the record in SOLR. Currently saved as multi-valued strings in SOLR. | marc_resource_tesim
| tag=020, code=a | Code `a` for tag 020 is used to represent ISBNs for the marc record | isbn_ssim |
| tag=300, code=aa/a(?) | Code `aa` or `a` (not sure yet) for tag 300 is used to represent material type for march record. Currently saved as multi-valued strings in SOLR. | material_type_display_tesim |
| tag=245, code=a | Code `a` for tag 245 is used to represent title for marc record. Currently saved as multi-valued strings in SOLR. | <ul><li>title_t (gets linked fields along with title, combined?)</li><li>title_display (without trailing punctuations)</li><li>title_vern_display (gets linked fields along with title?)</li></ul> |
| tag=245, code=b | Code `b` for tag 245 is used to represent subtitle for marc record. Currently saved as multi-valued strings in SOLR. | <ul><li>subtitle_t (gets linked fields along with subtitle, combined?)</li><li>subtitle_display (without trailing punctuations)</li><li>subtitle_vern_display (gets linked fields along with subtitle?)</li></ul> |
| <ul><li>tag=245, code=abnps</li><li>tag=130, code=[a-z]</li><li>tag=240, code=[a-gk-s]</li><li>tag=210, code=ab</li><li>tag=222, code=ab</li><li>tag=242, code=abnp</li><li>tag=243, code=[a-gk-s]</li><li>tag=246, code=[a-gnp]</li><li>tag=247, code=[a-gnp]</li></ul> | <ul><li>Codes a,b,n,p,s for tag 245</li><li>Codes a to z for tag 130</li><li>Codes a to g and k to s for tag 240</li><li>Codes a and b for tag 210</li><li>Codes a and b for tag 222</li><li>Codes a,b,n,p for tag 242</li><li>Codes a to g and k to s for tag 243</li><li>Codes a to g, n, and p for tag 246</li><li>Codes a to g, n, and p for tag 247</li></ul>Above tags and codes are used to represent additional/alternate titles for the marc record. Currently saved as multi-valued strings in SOLR. | title_addl_t |
| <ul><li>tag=700, codes=[gk-pr-t]</li><li>tag=710, code=[fgk-t]</li><li>tag=711, code=fgklnpst</li><li>tag=730, code=[a-gk-t]</li><li>tag=740, code=anp</li></ul> | <ul><li>Codes g, k to p, and r to t for tag 700</li><li>Codes f,g,k to t for tag 710</li><li>Codes f,g,k,l,n,p,s,t for tag 711</li><li>Codes a to g and k to t for tag 730</li><li>Codes a,n,p for tag 740</li></ul>Above codes are used to represent more titles in a marc record. Currently saved as multi-valued strings in SOLR. | title_added_entry_t |
| <ul><li>tag=440, code=anpv</li><li>tag=490, code=av</li></ul> | <ul><li>Codes a,n,p,v for tag 440</li><li>Codes a,v for tag 490</li></ul>Above codes series titles in marc record | title_series_t |
| tag=n/a, code=n/a | Sorts titles. Currently saved as single valued string in SOLR. | title_sort |
| <ul><li>tag=100, code=abcegqu</li><li>tag=110, code=abcdegnu</li><li>tag=111, code=acdegjnqu</li></ul> | <ul><li>Codes a,b,c,e,g,q,u for tag 100</li><li>Codes a,b,c,d,e,g,n,u for tag 110</li><li>Codes a,c,d,e,g,j,n,q,u for tag 111</li></ul>Above codes are primary Author info/name in marc records. Currently saved as multi-valued strings in SOLR. | author_tesim |
| <ul><li>tag=700, code=abcegqu</li><li>tag=710, code=abcdegnu</li><li>tag=711, code=acdegjnqu</li></ul> | <ul><li>Codes a,b,c,e,g,q,u for tag 700</li><li>Codes a,b,c,d,e,g,n,u for tag 710</li><li>Codes a,b,c,d,e,g,j,n,q,u for tag 711</li></ul>Above codes are additional author info and names? in marc records. Currently saved as multi-valued strings in SOLR. | author_addl_tesim |
| <ul><li>tag=100, code=abcdq</li><li>tag=110, code=[a-z]</li><li>tag=111, code=[a-z]</li></ul> | <ul><li>Codes a,b,c,d,q for tag 100</li><li>Codes a to z for tag 110</li><li>Codes a to z for tag 111</li></ul>In marc records, above codes are author info to be displayed | <ul><li>author_display_tesim</li><li>author_vern_display_tesim</li></ul> |
| tag=n/a, code=n/a | Sorts author info/names? Currently saved as single valued string in SOLR. | author_ssort |
| <ul><li>tag=600, code=[a-u]</li><li>tag=610, code=[a-u]</li><li>tag=611, code=[a-u]</li><li>tag=630, code=[a-t]</li><li>tag=650, code=[a-e]</li><li>tag=651, code=ae</li><li>tag=653, code=aa</li><li>tag=654, code=[a-e]</li><li>tag=655, code=[a-c]</li></ul> | <ul><li>Codes a to u for tag 600</li><li>Codes a to u for tag 610</li><li>Codes a to u for tag 611</li><li>Codes a to t for tag 630</li><li>Codes a to e for tag 650</li><li>Codes a,e for tag 651</li><li>Codes a,a (if indicator 2 = 6) for tag 653</li><li>Codes a to e for tag 654</li><li>Codes a to c for tag 655</li></ul>Above codes are used to represent subjects for a marc record. Currently saved as multi-valued strings in SOLR. | subject_tesim |
| <ul><li>tag=600, code=[v-z]</li><li>tag=610, code=[v-z]</li><li>tag=611, code=[v-z]</li><li>tag=630, code=[v-z]</li><li>tag=650, code=[v-z]</li><li>tag=651, code=[v-z]</li><li>tag=654, code=[v-z]</li><li>tag=655, code=[v-z]</li></ul> | <ul><li>Codes v to z for tags 600, 610, 611, 630, 650, 651, 654, 655</li></ul>Above codes are used to represent additional subjects in a marc record. Currently saved as multi-valued strings in SOLR. | subject_addl_tesim |
| <ul><li>tag=600, code=abcdq</li><li>tag=610, code=ab</li><li>tag=611, code=ab</li><li>tag=630, code=aa</li><li>tag=650, code=aa</li><li>tag=653, code=aa</li><li>tag=654, code=ab</li><li>tag=655, code=ab</li></ul> | <ul><li>Codes a,b,c,d,q for tag 600</li><li>Codes a,b for tag 610</li><li>Codes a,b for tag 611</li><li>Code a if indicator2=0, for tag 630</li><li>Code a if indicator2=0, for tag 650</li><li>Code a for tag 653</li><li>Codes a,b for tag 654</li><li>Codes a,b for tag 655</li></ul>Above codes are used to represent subjects topics/more subjects info. Currently saved as multi-valued strings in SOLR. | subject_topic_facet_tesim |
| <ul><li>tag=650, code=y</li><li>tag=651, code=y</li><li>tag=654, code=y</li><li>tag=655, code=y</li></ul> | <ul><li>Code y for tag 650, 651, 654, 655</li></ul>Above codes are used to represent subject eras in marc records. Currently saved as multi-valued strings in SOLR. | subject_era_facet_tesim |
| <ul><li>tag=651, code=a</li><li>tag=650, code=z</li></ul> | <ul><li>Code a for tag 651</li><li>Code z for tag 651</li></ul>Above codes are used to represent subject geo locations in marc fields (not sure?). Currently saved as multi-valued strings in SOLR. | subject_geo_facet_tesim |
| <ul><li>tag=260, code=a</li></ul> | Code a for tag 260 is used to represent publication/publisher name and info | <ul><li>published_display_tesim</li><li>published_vern_display_tesim</li></ul> |
| tag=n/a, code=n/a | Saves date for publication | pub_date_tesi |
| tag=050 code=ab | Code a,b for tag 050 represents LC Call Number in a marc record. Currently saved as single valued field in SOLR. | lc_callnum_display_ssi |
| tag=050 code=a, position=[0] | Code a for tag 050 is used to represent LC 1 letter call number which is mapped using callnumber properties. Looking only for the first character at this tag-code. Then use that first character in callnumber properties mapper. Currently saved as single valued field in SOLR. | lc_1letter_facet_tesi |
| tag=050, code=a | Code a for tag 050 is extracted and mapped against lc_alpha mapper? not sure what this field is used for. Same tag-code is used to save `lc_b4cutter_facet_tesi` in SOLR. Currently saved as single valued field in SOLR. | <ul><li>lc_alpha_facet_tesi</li><li>lc_b4cutter_facet_tesi</li></ul> |
| tag=n/a, code=n/a | Fields used to save FullText and Supplemental URLs? | <ul><li>url_fulltext_display_tesim</li><li>url_suppl_display_tesim</li></ul> |

All above descriptions are first pass at understanding these mappings using this document: https://knowledge.exlibrisgroup.com/Alma/Product_Documentation/010Alma_Online_Help_(English)/040Resource_Management/040Metadata_Management/180Search_Indexes/050MARC_21_Search_Indexes

Additional mappings for format (need to confirm these):
### format mapping
####    leader 06-07
<ul>
	<li>map.format.aa = Book</li>
	<li>map.format.ab = Serial</li>
	<li>map.format.ac = Book</li>
	<li>map.format.ad = Book</li>
	<li>map.format.ai = Serial</li>
	<li>map.format.am = Book</li>
	<li>map.format.an = Book</li>
	<li>map.format.as = Serial</li>
	<li>map.format.ta = Book</li>
	<li>map.format.tc = Book</li>
	<li>map.format.tm = Book</li>
	<li>map.format.ts = Book</li>
	<li>map.format.rm = Mixed Materials</li>
</ul>

####    leader 06
<ul>
	<li>map.format.a = Book</li>
	<li>map.format.c = Musical Score</li>
	<li>map.format.d = Musical Score</li>
	<li>map.format.e = Map</li>
	<li>map.format.f = Map</li>
	<li>map.format.g = Visual Material</li>
	<li>map.format.i = Non-musical Recording</li>
	<li>map.format.j = Musical Recording</li>
	<li>map.format.k = Visual Material</li>
	<li>map.format.m = Computer File</li>
	<li>map.format.o = Other</li>
</ul>


####    007[0]  when it doesn't clash with above
<ul>
	<li>map.format.h = Microform</li>
	<li>map.format.q = Musical Score</li>
	<li>map.format.v = Video</li>
</ul>

####    none of the above
<ul><li>map.format = Unknown</li></ul>

#### identifying electronic resources
<ul>
	<li>map.format_type.c = Electronic Resource</li>
	<li>map.format_type.sr = Electronic Resource</li>
	<li>map.format_type.sz = Electronic Resource</li>
	<li>map.format_type.vr = Electronic Resource</li>
	<li>map.format_type.vz = Electronic Resource</li>
</ul>

#### none of the above
<ul><li>map.format_type = Physical Resource</li></ul>

`pattern_map.lc_alpha.pattern_0 = ^([A-Z]{1,3})\\d+.*=>$1`
`pattern_map.isbn_clean.pattern_0 = ([- 0-9]*[0-9]).*=>$1`



n/a in the table indicates no tag/code present in marc field.
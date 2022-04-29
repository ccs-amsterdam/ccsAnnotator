
function() {

library(corpustools)
library(ccsAnnotator)
sentiment = annotation_question('sentiment', 'What is the sentiment of this text?',
                                codes = c(Negative = 'red', Neutral = 'grey', Positive = 'green'))
codingjob = create_job('Sotu sentiment',
                       create_units(mini_sotu, id='id', text='text', meta=c('name','year')),
                       create_codebook(sentiment))
backend_connect('http://localhost:5000/annotator', 'test@user.com')
upload_job(codingjob)


jsonlite::toJSON(codingjob$codebook)
job_db = create_job_db(codingjob, overwrite = T)


library(corpustools)
library(tidyverse)
d = sotu_texts
colnames(d)
d$year = gsub('-.*','',d$date)
d$id = paste0(gsub('.* ', '', d$president), d$year)
d = d %>%
  group_by(id) %>%
  mutate(paragraph = 1:n())
d = data.frame(id = paste(d$id, d$paragraph, sep='.'),
               title = paste0(d$president),
               text = d$text,
               president = d$president,
               paragraph = d$paragraph,
               date = d$date)
d = d[sample(1:nrow(d), 20, replace=F),]
cj = create_job('Sotu sentiment',
                create_units(d, id='id', meta=c('date', 'paragraph'), text_fields(
                  text_field('title', bold = T, size = 1.2),
                  text_field('text')
                )),
                create_codebook(sentiment))
jsonlite::toJSON(cj$units)




?create_units
library(ccsAnnotator)

## create codebook
sentiment = annotation_variable('sentiment', 'assign sentiment to words',
                                codes = c(Negative = 'red', Neutral = 'grey', Positive = 'green'))

mini_sotu$id = c('test','of','ID','werkt')



codingjob1 = create_job('Sotu sentiment crowd',
                       create_units(mini_sotu, id='id', text='text', meta=c('name','year')),
                       create_codebook(sentiment))

codingjob2 = create_job('Sotu sentiment crowd n=2 back=F',
                       create_units(mini_sotu, id='id', text='text', meta=c('name','year')),
                       create_codebook(sentiment),
                       rules_crowdcoding(units_per_coder=2, can_seek_backwards = F))

codingjob3 = create_job('Sotu sentiment fixed',
                       create_units(mini_sotu, id='id', text='text', meta=c('name','year')),
                       create_codebook(sentiment),
                       rules_fixedset())

codingjob4 = create_job('Sotu sentiment fixed forward=T',
                       create_units(mini_sotu, id='id', text='text', meta=c('name','year')),
                       create_codebook(sentiment),
                       rules_fixedset(can_seek_forwards = T))

codingjob5 = create_job('Sotu paragraph sentiment crowd n=5',
                        create_units(sotu_texts, id='id', text='text', meta=c('party','date')),
                        create_codebook(sentiment),
                        rules_crowdcoding(units_per_coder=5))


backend_connect('http://localhost:5000/annotator', 'test@user.com')
upload_job(codingjob1)
upload_job(codingjob2)
upload_job(codingjob3)
upload_job(codingjob4)
upload_job(codingjob5)

job_db = create_job_db(codingjob5, overwrite=T)
start_annotator(job_db, background=T)


backend_connect('https://amcat4.labs.vu.nl/api/annotator', 'test@user.com')
upload_job(codingjob)


test = codingjob$units[[1]]
test$id

#jsonlite::write_json(jsonlite::toJSON(list(codebook = codingjob$codebook)),
#                     path = '~/projects/ccs-annotator-client/public/codebook/sentimentAnnotation.json')


#jsonlite::write_json(jsonlite::toJSON(list(units=codingjob$units)),
#                     path = '~/projects/ccs-annotator-client/public/units/sotu.json')


job_db = create_job_db(codingjob, overwrite = T)


## run in current session. Auto opens annotator in browser
job_db = start_annotator(job_db)

## run in rstudio background job. Auto opens annotator in viewer (if available)
job_db = start_annotator(job_db, background = T)

gimme_annotations()   ## get annotations from current/most recent job
gimme_annotations(job_db) ## more transparent, and works across sessions

## if not auto start from start_annotator
view_annotator()  ## checks if viewer is available, otherwise use browser
view_annotator(in_browser=T)


annotations = gimme_annotations()

#annotations = gimme_annotations()
codingjob = create_job('Sotu sentiment',
                       create_units(mini_sotu, id='id', text='text', meta=c('name','year')),
                       create_codebook(sentiment),
                       annotations)

codingjob$units[[2]]$unit$importedAnnotations

job_db = create_job_db(codingjob, overwrite = T)


## run in current session. Auto opens annotator in browser
job_db = start_annotator(job_db)


####################
####################


## test with importing annotations
library(corpustools)
library(ccsAnnotator)

tc = create_tcorpus(mini_sotu, c('name','text'), 'id', remember_spaces = T)
tc$code_dictionary(quanteda::data_dictionary_LSD2015, column = 'sentiment')

units = untokenize(tc)
annotations = export_span_annotations(tc, 'sentiment')
annotations$id = annotations$doc_id

unique(annotations[,c('variable','value')])
sentiment = annotation_variable('sentiment', 'Annotate the sentiment of words', only_edit = T, multiple=T,
          codes = c(positive='green', neg_negative='green', negative='red', neg_positive='red'))


codingjob = create_job('Sotu sentiment',
                       create_units(units, id='doc_id', text='text'),
                       create_codebook(sentiment),
                       annotations)



job_db = create_job_db(codingjob, overwrite=T)
start_annotator(job_db, background=T)




codingjob = create_job('test nieuw 1',
                       create_units(units, id='doc_id', text='text'),
                       create_codebook(sentiment),
                       annotations)

codingjob$rules

backend_connect('http://localhost:5000/annotator', 'test@user.com')
upload_job(codingjob)
}



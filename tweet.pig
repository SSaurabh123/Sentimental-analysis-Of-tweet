REGISTER '/home/cloudera/Desktop/elephant-bird-hadoop-compat-4.1.jar';


REGISTER '/home/cloudera/Desktop/elephant-bird-pig-4.1.jar';


REGISTER '/home/cloudera/Desktop/json-simple-1.1.1.jar';



load_tweets = load '/user/cloudera/Tweets/twitterstream.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') AS  myMap;


dump load_tweets

extract_details = foreach load_tweets generate myMap#'user' as user,myMap#'id' as id,myMap#'text' as text;



token = foreach extract_details generate id,text,FLATTEN(TOKENIZE(text)) as word;
dump token;




dictionary = load '/user/cloudera/Tweets/AFINN.txt' using PigStorage('\t') as (word:chararray,rating:int);



word_rating = join token by word left outer,dictionary by word using 'replicated';

dump word_rating;



rating = foreach word_rating generate token::id as id,token::text as text,dictionary::rating as rate;



word_group = group rating by(id,text);



avg_rate = foreach word_group generate group,AVG(rating.rate) as tweet_rating;

dump avg_rate;

store avg_rate into '/user/cloudera/Tweets/Tweet_Rating/';

#!/usr/bin/python3

'''script to seed the dynamodb for runes'''
import logging
import boto3

runes_nordic_names = ['Mannaz', 'Gebo', 'Ansuz', 'Othila', 'Uruz', 'Perth',\
'Nauthiz', 'Inguz', 'Eihwaz', 'Algiz', 'Fehu', 'Wunjo', 'Jera', 'Kano', \
'Teiwaz', 'Berkana', 'Ehwaz', 'Laguz', 'Hagalz', 'Raido', 'Thurisa', 'Dagaz',\
'Isa', 'Sowelu', 'Odin']
runes_english_names = ['The Self', 'Partnership', 'Signals', 'Separation', \
'Strength', 'Initiation', 'Constraint', 'Fertility', 'Defense', 'Protection',\
 'Possessions', 'Joy', 'Harvest', 'Opening', 'Warrior', 'Growth', 'Movement', \
'Flow', 'Disruption', 'Journey', 'Gateway', 'Breakthrough', 'Standstill', \
'Wholeness', 'Unknowable']
runes_traditional_meanings = ['Man, woman, the human race', 'A gift, offerings'\
' from the gods or from chiefs to loyal followers', 'The Norse god Loki, mouth'\
'(source of Divine utterances), river mouth', 'Inherited property or possess'\
'ions, also native land, home', 'Strength, sacrificial animal, the aurochs '\
'(bos primigenius), species of wild ox', 'Uncertain meaning, a secret '\
'matter', 'Need, neccessity, constraint, cause of human sorrow, lessons, '\
'hardship', 'Ing, legendary hero, later a god', 'Yew tree, a bow made of yew,'\
' avertive powers, runic calendars or "primstaves"', 'Protection, the elk, '\
'sedge or eelgrass', 'Cattle, goods, vital communinity wealth', 'Joy, absence'\
' of suffering and sorrow (see Cynewulf\'s runic passages)', 'Year, harvest, '\
'a fruitful part of the year', 'Torch, skiff, associated with the goddess '\
'Nerthus', 'Victory in battle, a guiding planet or star, the Norse god Tiw '\
'(whose name survives in Tuesday)', 'Birch tree, associated with fertility '\
'rites, rebirth, new life', 'Horse, associated with the course of the sun',\
'Water, sea, a fertility source (see Grendel\'s Mere in Beowulf)', 'Hail '\
'sleet, natural forces that damage', 'A journey, riding, carriage, refers '\
'to the soul after death; a journey charm', 'Giant, demon, a thorn, the '\
'Norse god Thor', 'Day, God\'s light, prosperity and fruitfulnes', 'Ice, '\
'freezing, (in the Prose Edda, the frost-giant Ymir is born of ice)', \
'The sun', 'The Divine in all human transactions']

def put_rune(dbclient, iterate, nord_name, english_name, rune_meaning):
    '''uses defined values to put in dynamodb'''
    response = dbclient.put_item(TableName='rune_table', Item={'runeId': \
    {'N': str(iterate)}, 'Description': {'S': rune_meaning}, 'englishName': \
    {'S': english_name}, 'nordicName': {'S': nord_name}})
    logging.info(response)

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    session = boto3.Session()
    client = boto3.client('dynamodb')
    for count, eng_name in enumerate(runes_english_names):
        #uses the length of the list to refrence ordered lists
        put_rune(client, count, runes_nordic_names[count], \
        eng_name, runes_traditional_meanings[count])

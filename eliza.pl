#!/usr/bin/perl
use strict;
##########################
# Programmer Yuval Lando #
##########################

#This is a simulation of rogerian psychotherapist.
#To end it press goodbye.


#forword decleration
sub buildWordGraph;
sub keySearch;
my %conj;
my @key1;
my @key2;
my @response;

#The program itself. Run a repl that simulate rogerian psychotherapist.
sub eliza
{
  my %key1Graph;
  my %key2Graph;
  buildWordGraph \@key1,\%key1Graph;
  buildWordGraph \@key2,\%key2Graph;
  print "May I help you?\n";
  my $lastInput="";
  for (;;) {
    my $input=<>;
    
    next if $input eq "\n";
    
    if ($lastInput && $lastInput eq $input) {
      print "Please do not repeat yourself.\n";
      next;
    }
    $lastInput=$input;
    
    $input=lc $input;
    $input=~ s/(,|;|\?|\.)/ /g;
    $input=~ s/'|"//g;
    my @wordList=split ' ',$input;
   
    last if (@wordList==1 && $wordList[0] eq 'goodbye');

    my ($key,$pos)=keySearch \@wordList,\%key1Graph;
    if ($key==-1) {
      ($key,$pos)=keySearch \@wordList,\%key2Graph;
    }
    $key=1 if ($key==-1);
    $key=16 if $key>16 && $key<22;
    $key-=5 if $key>=22;
    my $resIndex=$response[$key-1]->[0];
    my $res=$response[$key-1]->[1]->[$resIndex];
    $resIndex++;
    $resIndex=0 if ($resIndex==@{$response[$key-1]->[1]});
    $response[$key-1]->[0]=$resIndex;
    if ($res=~ m/\*/) {
      $res=~ s/\*//;
      print $res;
      for my $j ($pos..$#wordList) {
        my $word=$wordList[$j];
        my $trans=$conj{$word};
        if (defined $trans) {
          print $trans;
        }
        else {
          print $word;
        }
        print " " if $j<$#wordList;
      }
      print "?";
    }
    else {
      print $res;
    }
    print "\n";
  } 
}




#gets [[text rank] [text2 rank] ...] and a reference to result
sub buildWordGraph
{
  my $textAndRanks=shift;
  my $result=shift;
  for (@{$textAndRanks}) {
    my ($text,$rank)=@{$_};
    my $pos;
    my $ptr=$result;
    my @words=split ' ',$text;
    my $tempWord;
    for ($pos=0;$pos<@words;$pos++) {
      $tempWord=$words[$pos];
      if (defined $ptr->{$tempWord}) {
        $ptr=$ptr->{$tempWord};
      }
      else {
        last;
      }
    }
    my %rest;
    my $lastPtr=\$rank;
    for my $pos2 (reverse (($pos+1)..$#words)) {
      my $temp={}; 
      $temp->{$words[$pos2]}=$lastPtr;
      $lastPtr=$temp;
    }
    $ptr->{$tempWord}=$lastPtr; 
  }
}

#gets a wordList and wordGraph search for sequence of words
#If it find the return the (priority of words,position of rest of words)
#If it dont find the return (-1,undefine)
sub keySearch
{
   my $wordList=shift;
   my $wordGraph=shift;
   my $len=$#{$wordList};
   my $max=-1;
   my $pos;
   my $thisKey;
   for my $i (0..$len) {
     my $ptr=$wordGraph;
     for my $j ($i..$len) {
       $ptr=$ptr->{$wordList->[$j]};
       if (defined $ptr) { 
         unless (ref($ptr) eq "HASH") {
           #A priority value
           $thisKey=${$ptr};
           if ($thisKey>$max) {
             $max=$thisKey;
             $pos=$j+1;
           }
           last;
         }
       }
       else {
          #The word don't exist
          last;
       }
     }
   }
   return ($max,$pos);
}

%conj=(
  "i"=>"you",
  "yourself"=>"myself",
  "are"=>"am",
  "am"=>"are",
  "were"=>"was",
  "was"=>"were",
  "you"=>"me",
  "your"=>"my",
  "my"=>"your",
  "ive"=>"youve",
  "youve"=>"ive",
  "im"=>"youre",
  "youre"=>"im",
  "me"=>"you"
);

@key1=(
["i dont", 6],
["i feel", 7],
["i cant", 11],
["i am", 12],
["i want", 15],
["are you", 10],
["you are", 4],
["your", 30],
["im", 13],
["youre", 5],
["can you", 2],
["can i", 3],
["why dont you", 8],
["why i", 9],
["what", 16],
["how", 17],
["who", 18],
["where", 19],
["when", 20],
["name", 22],
["names", 22],
["cause", 23],
["because", 23],
["sorry", 24],
["dream", 25],
["dreams", 25],
["hello", 26],
["hi", 27],
["maybe", 28],
["no", 29],
["always", 31],
["think", 32],
["alike", 33],
["yes", 34],
["friend", 35],
["friends", 35],
["comer", 36],
["machine", 36],
["machines", 36],
["comers", 36]);

@key2=(
["you", 14],
["why", 21]);

@response=(
[0,[
  "What does that suggest to you?",
  "I see.",
  "Im not sure i understand you fully.",
  "Come, come, elucidate your thoughts.",
  "Can you elaborate on that?",
  "That is quite interesting.",
  "Do you have any psychological problems?",
  "You dont say."]],
[0,[
  "Dont you believe that i can *",
  "Perhaps you would like to be able to *",
  "You want me to be able to *",
  "What makes you think i could *"]],
[0,[
  "Perhaps you dont want to *",
  "Do you want to be able to *",
  "Do you think you could not *"]],
[0,[
  "What makes you think i am *",
  "Does it please you to believe i am *",
  "Perhaps you would like to be *",
  "Do you sometimes wish you were *"]],
[0,[
  "What makes you think i am *",
  "Does it please you to believe i am *",
  "Perhaps you would like to be *",
  "Do you sometimes wish you were *"]],
[0,[
  "Dont you really *",
  "Why dont you *",
  "Do you wish to be able to *",
  "Does that trouble you? *"]],
[0,[
  "Tell me more about such feelings.",
  "Do you often feel *",
  "Do you enjoy feeling *"]],
[0,[
  "Do you really believe i dont *",
  "Perhaps in good time i will *",
  "Do you want me to *"]],
[0,[
  "Do you think you should be able to *",
  "Why cant you *"]],
[0,[
  "Why are you interested in whether or not i am *",
  "Would you prefer if i were not *",
  "Perhaps in your fantasies i am *"]],
[0,[
  "How do you know you cant *",
  "Have you tried?",
  "Perhaps you can now *"]],
[0,[
  "Did you come to me because you are *",
  "How long have you been *",
  "Do you believe it is normal to be *",
  "Do you enjoy being *"]],
[0,[
  "Did you come to me because you are *",
  "How long have you been *",
  "Do you believe it is normal to be *",
  "Do you enjoy being *"]],
[0,[
  "We were discussing you -- not me.",
  "Oh, i *",
  "Youre not really talking about me, are you?",
  "Oh, yeah?"]],
[0,[
  "What would it mean to you if you got *",
  "Why do you want *",
  "Suppose you soon got *",
  "What if you never got *",
  "I sometimes also want *"]],
[0,[
  "Why do you ask?",
  "Does that question interest you?",
  "What answer would please you most?",
  "What do you think?",
  "Are such questions on your mind often?",
  "What is it that you really want to know?",
  "Have you asked anyone else?",
  "Have you asked such questions before?",
  "What else comes to mind when you ask that?",
  "Are you asking me?"]],
[0,[
  "Names dont interest me.",
  "I dont care about names -- please go on."]],
[0,[
  "Is that the real reason?",
  "Dont any other reasons come to mind?",
  "Does that reason explain anything else?",
  "What other reasons might there be?"]],
[0,[
  "Please dont apologize.",
  "Apologies are not necessary.",
  "What feelings do you have when you apologize?",
  "Dont be so defensive."]],
[0,[
  "What does that dream suggest to you?",
  "Do you dream often?",
  "What persons appear in your dreams?",
  "Are you disturbed by your dreams?"]],
[0,[
  "How do you do -- please state your problem.",
  "Enough salutations -- what do you want?"]],
[0,[
  "How do you do -- please state your problem.",
  "Enough salutations -- what do you want?"]],
[0,[
  "You dont seem quite certain.",
  "Why the uncertain tone?",
  "Cant you be more positive?",
  "You arent sure?",
  "Dont you know?"]],
[0,[
  "Are you saying no just to be negative?",
  "You are being a bit negative.",
  "Why not?",
  "Are you sure?",
  "Why no?"]],
[0,[
  "Why are you concerned about my *",
  "What about your own *"]],
[0,[
  "Can you think of a specific example?",
  "When?",
  "What are you thinking of?",
  "Really, always?"]],
[0,[
  "Do you really think so?",
  "But you are not sure you *",
  "Do you doubt you *"]],
[0,[
  "In what way?",
  "What resemblance do you see?",
  "What other connections do you see?",
  "How?"]],
[0,[
  "You seem quite positive.",
  "Are you sure?",
  "I see.",
  "I understand."]],
[0,[
  "Why do you bring up the topic of friends?",
  "Do your friends worry you?",
  "Are you sure you have any friends?",
  "Do your friends pick on you?"]],
[0,[
  "Do computers worry you?",
  "Are you talking about me in particular?",
  "Are you frightened by machines?",
  "Why do you mention computers?",
  "What do you think machines have to do with your problem?",
  "Dont you think computers can help people?",
  "What is it about machines that worries you?"]]);

eliza();

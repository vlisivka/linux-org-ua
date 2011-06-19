// Original idea of Orfo system belongs to Dmitry Koteroff.
// Оригінальна ідея системи "чистки" орфографії належить Дмитру Котерову.

var durochka = new Object;

durochka.hq         = "/cgi-bin/orfo/send.pl"; 
durochka.contlen    = 10;
durochka.contunit   = "word";
durochka.seltag1    = "(!!!)";
durochka.seltag2    = "(!!!)";
durochka.version    = "2.2";

durochka.badbrowser = "Ваш переглядач не підтримує функцію перехоплення виділеного текста або IFRAME. Можливо, застаріла версія.";
durochka.toobig     = "Ви виділили аж занадто великий обсяг тексту!";
durochka.subject    = "Орфографічна помилка на сайті www.linux.org.ua";
durochka.docmsg     = "Документ:";
durochka.intextmsg  = "Орфографічна помилка в тексті:";
durochka.ifsendmsg  = "Надіслати повідомлення автору?\nВаш браузер залишиться на цій же ж сторінці.";

document.writeln(
'<form name="durochka_form" target=durochka_frame action="'+durochka.hq+'" method="post">' +
	'	<iframe name="durochka_frame" valign="top" width="10" height="10" border="0" style="position:absolute;visibility:hidden;width:10px;height:10px;"></iframe>' +
	'	<input type=hidden name="subject" value="'+durochka.subject+'">' +
	'	<input type=hidden name="referrer" value="">' +
	'	<input type=hidden name="address" value="">' +
	'	<input type=hidden name="context" value="">' +
'</form>'
);


function BODY_onkeypress(e)
{	var pressed=0;
	if(!durochka.ready) return;
//	alert(e.keyCode+" "+e.ctrlKey);

	var we=null;
	if(window.event) we=window.event;
	else if(parent && parent.event) we=parent.event;

	if(we) {
		// IE
		pressed=we.keyCode==10;
	} else if(e) {
		// NN
		pressed = 
			(e.which==10 && e.modifiers==2) || // NN4
			(e.keyCode==0 && e.charCode==106 && e.ctrlKey) ||
			(e.keyCode==13 && e.ctrlKey) // Mozilla
	}
	if(pressed) durochka_do();
}

function durochka_strip_tags(text) {
	for(var s=0; s<text.length; s++) {
		if(text.charAt(s)=='<') {
			var e=text.indexOf('>',s); if(e<=0 || e==false) continue;
			text=text.substring(0,s)+text.substring(e+1); s--;
		}
	}
	return text;
}

function durochka_strip_slashn(text) {
	for(var s=0; s<text.length; s++) {
		if(text.charAt(s)=='\n' || text.charAt(s)=='\r') {
			text=text.substring(0,s)+" "+text.substring(s+1);
			s--;
		}
	}
	return text;
}

function durochka_do() {
	var text=null, context=null;
	if(navigator.appName.indexOf("Netscape")!=-1 && eval(navigator.appVersion.substring(0,1))<5) {
		alert(durochka.badbrowser);
		return;
	}

	var w = parent? parent : window;

	var selection = null;
	if(w.getSelection) {
		context=text=w.getSelection();
	} else if(w.document.getSelection) {
		context=text=durochka_strip_tags(w.document.getSelection());
	} else {
		selection = w.document.selection;
	}
	if(selection) {
		var sel = text = selection.createRange().text;
		var s=0; while(text.charAt(s)==" " || text.charAt(s)=="\n") s++;
		var e=0; while(text.charAt(text.length-e-1)==" " || text.charAt(text.length-e-1)=="\n") e++;
		var rngA=selection.createRange();
		rngA.moveStart(durochka.contunit,-durochka.contlen);
		rngA.moveEnd("character",-text.length+s);
		var rngB=selection.createRange();
		rngB.moveEnd(durochka.contunit,durochka.contlen);
		rngB.moveStart("character",text.length-e);
		text    = text.substring(s,text.length-e);
		context = rngA.text+durochka.seltag1+text+durochka.seltag2+rngB.text;
	}
	if(text==null) { alert(durochka.badbrowser); return; }
	if(context.length>512) {
		alert(durochka.toobig);
		return;
	}
	var url = w.document.location;
	if(confirm(durochka.docmsg+"\n    "+url+"\n"+durochka.intextmsg+'\n    "'+durochka_strip_slashn(context)+'"\n\n'+durochka.ifsendmsg)) {
		durochka_send(text,url,context);
		// alert(text + "\n\n" + url + "\n\n" + context);
	}
}

function durochka_send(text,url,context)
{
        var form=document.forms['durochka_form'];
	if(!form) alert("Не можу відіслати - форма durochka_form не існує");
	if(!context) context=text;
	form["address"].value=url;
	form["context"].value=context;
	form["referrer"].value=top.document.location;
	form.submit();
}

durochka.ready = true;
document.onkeypress = BODY_onkeypress;
if(parent) parent.document.onkeypress = BODY_onkeypress;

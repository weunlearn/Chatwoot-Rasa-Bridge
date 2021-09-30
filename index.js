var axios = require('axios');
const util = require('util');
const AWS = require("aws-sdk");
AWS.config.update({region: 'ap-south-1'});


let rasa_url = 'https://rasawulu.ddns.net';
let chatwoot_url = 'https://weunlearn.hopto.org';
let chatwoot_bot_token = 'tLXXAhti8tWK46NW8TfFVSwj';
exports.handler = async (event) => {
   //console.log(util.inspect(req.body, false, null, true /* enable colors */))
   let data = JSON.parse(event.body);
   console.log(data);
   let message_type = data.message_type;
   let message = data.content;
   let conversation = data.conversation.id;
   let contact = data.sender.id;
   let inbox = data.conversation.status;
   let custom_attributes = data.conversation.meta.sender.custom_attributes;
   // TODO : Check for submitted values and assign to message field
   console.log("Attrs: ", data.content_attributes.submitted_values);
   if (message_type == "incoming" && inbox == "pending"){

      let bot_response = await send_to_bot(contact, message);
      console.log(bot_response);
      for(let i=0;i<bot_response.length;i++){
         console.log("Body:", bot_response[i]);
         let resp = await send_to_chatwoot(conversation, bot_response[i], custom_attributes);
         console.log(resp);
      }
   }



};

async function send_to_bot(contact, message){
   const data = JSON.stringify({
      "sender": contact,
      "message": message
   });
   const config = {
      method: 'post',
      url: rasa_url + '/webhooks/rest/webhook',
      headers: {
         'Content-Type': 'application/json'
      },
      data: data
   };
   try {
      const resp = await axios(config);
      //console.log(resp.data);
      return resp.data;
   }catch (e) {
      console.error(e);
   }
}
async function send_to_chatwoot(conversation, message, custom_attributes){
   let content;
   let content_attributes = {};
   let content_type = "text";
   if (custom_attributes.language!=null){
      var lang_code = custom_attributes.language;
      content = (await translator(lang_code, message.text)).TranslatedText;
      let options = [];
      if (message.buttons!=null) {
         content_type = "input_select";
         for (var i = 0; i < message.buttons.length; i++) {
            options.push({
               'title': await translator(lang_code, message.buttons[i].title),
               'value': message.buttons[i].payload
            })
         }
      }
      content_attributes = { 'items': options };
   }else{
      var lang_code = 'en';
      let options = [];
      content = message.text;
      if (message.buttons!=null) {
         content_type = "input_select";
         for (var i = 0; i < message.buttons.length; i++) {
            options.push({
               'title': message.buttons[i].title,
               'value': message.buttons[i].payload
            })
         }
      }
      content_attributes = { 'items': options };

   }


   console.log(content_attributes);
   let payload = JSON.stringify({
      "content": content,
      "content_attributes": content_attributes,
      "content_type": content_type
   });
   console.log("CONV:", conversation);
   const config = {
      method: 'post',
      url: chatwoot_url + '/api/v1/accounts/1/conversations/'+conversation+'/messages',
      headers: {
         'Content-Type': 'application/json',
         "api_access_token": chatwoot_bot_token
      },
      data: payload
   };
   try {
      const resp = await axios(config);
      return resp.data;
   }catch (e) {
      console.error(e);
   }
}

async function translator(target, text){
   let params = {
      SourceLanguageCode: 'en', /* required */
      TargetLanguageCode: target, /* required */
      Text: text, /* required */
      //TerminologyNames: [
      //   'STRING_VALUE',
      /* more items */
      //]
   };
   const translate = new AWS.Translate();
   return await translate.translateText(params).promise().then(
       function(data) {
          return data.TranslatedText;
       },
       function(error) {
          console.log(error);
          return null;
       }
   );

}
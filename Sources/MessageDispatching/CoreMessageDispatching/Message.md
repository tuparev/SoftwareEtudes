# Message


## To Do's
- Fully implement `MessageDescribing` protocol requirements (specially additional `init` methods) - Ani?
- `Message` - implement CoW (Ani)



```JSON
{
    { "nodes": [
        {
            "name": "AnisMessenger",
            "isRoot": true,
            "className": "Blah",
            "type": "message_emiter",
            "nextDispatchers": ["AnisFormatter"]
            
        },
        {
            "name": "AnisFormatterr",
            "isRoot": false,
            "type": "message_formatter",
            "nextDispatchers": ["AnisInterpreter"]
        },
         {
            "name": "AnisInterpreter",
            "isRoot": false,
            "type": "message_interpreter",
            "nextDispatchers": [],
            "atributes": {
                "codeMappings": "file:///tmp/mappings.json"
            }
        },
   }
    ]
    }   
}
```

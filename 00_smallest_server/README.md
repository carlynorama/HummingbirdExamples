
Works with swift run, fail(ed) in container with `(52) Empty reply from server`
 
Network error in container?

Things to try: 
- Add / route? [NO]
- Add something with a response body? [NO]
- Change from main.swift to App.swift @main { static main() } [NO]
- Moved HelloServer Source into this package's source. [YES!!]
    - remove / route [not it]
    - remove response body [not it]
    - remove specialized context [not it]
    - remove logging [not it]
    - remove Foundation [not it]
    - remove separate router call [not it]
    - fold build app builder back into App.swift [not it]
    - remove configuration [YES THAT'S IT! ]
- Add Argument Parser?

TODO:
- pm static build without the sdk, just for the mac. Same behavior? 



/* Todoit
// *Parse comments (lines)
// *Add jsfn
// *String formatting in toString
// *fn bindings
// *list macro
// *onclick fn

// touchmove fn
// expandmacro
// let
// multi list macros?
// & vardic
// destructing
// ns
// vector
// if
// do
*/

class BubbleScript {
  parse() {}
}

var bubl = {};
// bubl.bubl=bubl;

(function() {
class List {
  constructor(head, tail=null) {
    this.head = head;
    this.tail = tail;
  }

  push(val) {
    return new List(val, this);
  }

  peek() { return this.head; }
  pop()  { return this.tail; }

  get first() { return this.head; }
  get rest()  { return this.tail; }
  get next()  { return this.tail.head;}
  get last()  { return this.tail ? this.tail.last : this.head; }

  get second() { return this.tail.first; }
  get third()  { return this.tail.second; }
  get fourth() { return this.tail.third; }
  get fifth()  { return this.tail.fourth; }
  get sixth()  { return this.tail.fifth; }
  get seventh(){ return this.tail.sixth; }

  nth(n) { return n==1 ? this.head : this.tail.nth(n-1); }

  count() {
    return this.reduce(function(memo, i) {
      return memo + 1;
    }, 0);
  }

  shift() {
    return this.reverse().pop().reverse();
  }

  reverse() {
    if (!this.tail) return this;
    var list = new List(this.head);
    return this.tail.reduce(function(memo, i) {
      return memo.push(i);
    }, list);
  }

  conj(val) {
    return val.reduce(function(memo, i) {
      return memo.push(i);
    }, this);
  }

  join(delimiter=' ') {
    if(this.rest) {
      return this.first + delimiter + this.rest.join()
    } else {
      if (typeof this.head == "string") {
        return '"' + this.head +'"';
      }
      return this.head.toString()
    }
  }

  toString() {
    return "(" + this.join() + ")"
  }

  inspect() {
    "(" + map(function(q){q.inspect()}).join() + ")"
  }

  toArray() {
    if (this.rest) {
      return [this.first].concat(this.rest.toArray());
    } else {
      return [this.first];
    }
  }

  map (fn) {
    var tail=null, head;
    if (this.tail)
      tail = this.tail.map(fn);
    head = fn(this.head);
    return new List(head, tail);
  }

  reduce(fn, memo) {
    var a, b, c=this;
    if (memo==undefined) {
      a = this.head;
      c = this.rest;
      if (!c) {
        return a;
      } else {
        b = c.head;
        c = c.rest;
        memo = fn(a, b);
        if(!c)
          return memo;
      }
    }
    return c.push(memo).reduce(fn);
  }

  each (fn) {
    var result = fn(this.first);
    if (this.rest)
      return this.rest.each(fn);
    return result;
  }

}

class Glider {
  constructor(head, tail=null) {
    this.head = head;
    this.tail = tail;
  }

  peek() { return this.head; }
  push(val) {
    return new Glider(val, this); }
  pop() { return this.tail; }

  conj(...val){
    return val.reduce(function(i, memo) {
      memo.push(i);
    }, this);
  }

  get first() {
    if (this.tail) {
      return this.tail.first
    } else {
      return this.head
    }
  }

  get rest() {
    if (this._rest == null)
      if (this.tail)
        this._rest = new Glider(this.head, this.tail.rest);

    return this._rest;
  }

  get second() {
    return this.rest.first;
  }

  join(delimiter=' ') {
    if(this.rest)
      return this.first + delimiter + this.rest.join();
    else
      if (typeof this.first == "string")
        return '"' + this.first +'"';
      else
        return this.first + '';
  }

  toString() {
    this.inspect();
  }

  toString() {
    return "[" + this.join() + "]"
  }

  inspect() {
    "[" + this.map(function(q){q.inspect()}).join() + "]";
  }


  map(fn) {
    var q=null;
    if(this.tail)
      q = this.tail.map(fn);
    return new Glider(fn(this.head), q);
  }

  map(fn, ...aux) {
    var tail=null;



    var result = new Glider(fn(this.first,
      ...aux.map(function(q) {
        return q ? q.first : q})));

    if(!this.rest)
      return result;

    function into(a, b) {

      var c = new Glider(b.peek()); //b.peek());
      b = b.pop();

      while(b) {
        c = c.push(b.peek());
        b = b.pop();
      }
      while(c) {
        a = a.push(c.peek());
        c = c.pop();
      }

      return a;
    }

    return into(result, this.rest.map(fn,
      ...aux.map(function(q) {
        return q.rest})));

  }

  mapp(fn, ...aux) {
    var tail=null;

    var result = new Glider(fn(this.first,
      ...aux.map(function(q) {
        return q ? q.first : q})));

    return this.rest.map(function(...args) {
      return new Glider(fn(...args), result);
    }, ...aux.map(function(q) {
      return q.rest}));

  }

  reduce(fn, memo=null) {
    if (this.tail)
      memo = this.tail.reduce(fn, memo);
    return fn(this.head, memo);
  }

  each(fn) {
    if(this.tail)
      this.tail.each(fn);
    fn(this.head);
  }

}

class Symbol {
  constructor(value) {
    this.value = value;
  }

  toString() {
    return this.value;
  }
}

class Keyword {
  constructor(value) {
    this.value = value;
  }

  toString() {
    return this.value;
  }
}

class Quoted {
  constructor(value) {
    this.value = value;
  }

  unquote() {
    return this.value;
  }

  toString() {
    return "'" + this.value;
  }

  inspect() {
    return "'" + this.value.inspect;
  }
}

class Fn {
  constructor (bnd, args, body) {
    this.bnd  = bnd;
    this.args = args;
    this.body = body;
  }

  call(bnd, args) {
    return invoke(this.bnd, this,
      args.map(function(a){
        return evl(bnd,a)}))
  }
}

// fn(vector(symbol('a'),
//           symbol('b')),
//    list(symbol('+'),
//         symbol('a'),
//         symbol('b')))
//
// var a=symbol('a'),
//     b=symbol('b')
//
// fn([a] +(a b))

function fn(bnd, argsk, body) {
  return function(...argsv) {
    var bnd;
    argsv = argsv.map(function(a) { return evl(bnd,a)});
    bnd = createBnd(bnd, argsk, argsv);
    return body.each(function(exp){
      return evl(bnd, exp);
    });
  }
}

class Macro {
  constructor(bnd, args, body) {
    this.bnd  = bnd;
    this.args = args;
    this.body = body;
  }

  call(bnd, args) {
    return evl(this.bnd, invoke(bnd,this,args));
  }

  expand(bnd, args) {
    return invoke(bnd,this,args);
  }
}

function macro(bnd, argsk, body) {
  // var macro, expand;
  function expand(...argsv) {
    var bnd = createBnd(bnd, argsk, argsv);
    return body.each(function(exp){
      return oval(bnd, exp);
    });
  }
  function macro(...argsv) {
    return oval(bnd ,expand(...argsv));
  }
  macro.expand=expand;
  macro.signature=argsk;
  macro.identity=body;
  return macro;
}

function macro(ns, bnd, argsk, body) {
  // var macro, expand;
  function macro(argsv) {
    var bnd = createBnd(bnd, argsk, argsv);
    return evl(body, ns, bnd);
    return body.each(function(exp){
      return evl(exp, ns, bnd);
    });
  }
  macro.macro=true;
  macro.argsk=argsk;
  macro.body=body;
  return macro;
}

class Syntax {};
class LParen  extends Syntax {};
class LBrack  extends Syntax {};
class LSqigle extends Syntax {};
class SingleQ extends Syntax {};
class Dot     extends Syntax {};
class Slash   extends Syntax {};
class Space   extends Syntax {};

function each(c, fn) {
  c.forEach(fn);
}

// Adds peek() to array
if (Array.prototype.peek == undefined) {
  Array.prototype.peek = function() {
    return this[this.length-1];
  }
}

function bubbleParse(s, stack=[]) {
  var word = null,
      list = null,
      glider = null,
      stropen = false, // string open flag
      comment = false,
      zebra;

  // matchers
  var string = /^\".*\"$/,
      number = /^\d+$/,
      keyword = /^:.+$/;

  zebra = function () {
    switch (true) {
      case number.test(word):
        return parseInt(word);
      case /^(\d+)?\.\d+$/.test(word):
        return parseFloat(word);
      case keyword.test(word):
        return new Keyword(word.substr(1));
      case /^\"(.*)\"$/.test(word): //string
        return /^\"(.*)\"$/.exec(word)[1];
      case /^.+$/.test(word):
        word = new Symbol(word);
      case word == 'false':
        return false;
      case word == 'true':
        return true
    }
  }

  each(s.split(''), function(c) {
    if(stropen) {
      word += c;
      if (c == '"') {
        stropen = false;
        // stack.push(word);
        // word = null;
      }
      return;
    }
    if(comment) {
      if (c == "\n")
        comment = false;
      return;
    }
    switch (c) {
      case '(':
        stack.push(LParen);
        break;
      case '[':
        stack.push(LBrack);
        break;
      case '{':
        stack.push(LSqigl);
        break;
      case "'":
        stack.push(SingleQ);
        break;
      case '"':
        stropen = true;
        word = c;
        break;
      case ')':
        if (!word) word = stack.pop();
        if (word == LParen) {
          stack.push(new List)
          break;
        }

        if (typeof word == "string") {
          switch (true) {
            case number.test(word):
              word = parseInt(word);
              break;
            case /^(\d+)?\.\d+$/.test(word):
              word = parseFloat(word);
              break;
            case keyword.test(word):
              word  = new Keyword(word.substr(1));
              break;
            case /^\"(.*)\"$/.test(word):
              // strip quotes
              word = /^\"(.*)\"$/.exec(word)[1];
              break;
            case /^.+$/.test(word):
              // console.log(word);
              word = new Symbol(word);
          }
        }

        word = buildGetSend(stack, word);

        while (stack.peek() == SingleQ) {
          stack.pop()
          word = new Quoted(word);
        }

        list = new List(word);

        word = stack.pop();
        while(word != LParen) {
          list = list.push(word);
          word = stack.pop();
          console.log(stack)
          console.log(word)
          if (word == undefined)
            throw("That ain't right");
        }

        while (stack.peek() == SingleQ) {
          stack.pop();
          list = new Quoted(list);
        }

        word = null;
        stack.push(list);
        list == null;
        break;
      case ']':
        if (!word) word = stack.pop();
        if (word == LBrack) {
          stack.push(new Glider);
          break;
        }

        // word = zebra(word);
        // zebra!;
        switch (true) {
          case number.test(word):
            word = parseInt(word);
            break;
          case /^(\d+)?\.\d+$/.test(word):
            word = parseFloat(word);
            break;
          case keyword.test(word):
            word = new Keyword(word.substr(1));
            break;
          case /^\"(.*)\"$/.test(word): //string
            word = /^\"(.*)\"$/.exec(word)[1];
            break;
          case /^.+$/.test(word):
            word = new Symbol(word);
        }

        word = buildGetSend(stack, word);

        while (stack.peek() == SingleQ) {
          stack.pop();
          word = new Quoted.new(word);
        }

        tmp = [];
        while(word != LBrack) {
          tmp.push(word);
          word = stack.pop();
        }
        word = null;

        glider = new Glider(tmp.pop());
        while (tmp.length > 0) {
          glider = glider.push(tmp.pop());
        }

        while (stack.peek() == SingleQ) {
          stack.pop();
          glider = new Quoted(glider);
        }

        stack.push(glider);
        glider = null;
        break;
      case '}':
        // zebra();
        switch(word) {
          case 'true':
            word = true;
            break;
          case 'false':
            word = false;
            break;
          default:
            word = new Symbol(word);
        }

        tmp = null;
        while(word!=LSquigl) {
          tmp = [word,tmp];
          word = stack.pop();
        }

        word = null;
        obby = {};

        while(tmp) {
          [key,tmp]=tmp;
          [obby[key],tmp]=tmp;

          // key = tmp.head;
          // tmp = tmp.pop();
          // obj[key]=tmp.head;
          // tmp = tmp.pop();
        }

        stack.push(obby);

        // register=;

        break;
      case ' ':
      case "\n":
        // console.log(word, 'xoxo');
        if (word) {
          switch (true) {
            case number.test(word):
              word = parseInt(word);
              break;
            case /^(\d+)?\.\d+$/.test(word):
              word = parseFloat(word);
              break;
            case keyword.test(word):
              word = new Keyword(word.substr(1));
              break;
            case /^\"(.*)\"$/.test(word):
              // strip quotes
              word = /^\"(.*)\"$/.exec(word)[1];
              break;
            case /^.+$/.test(word):
              word = new Symbol(word);
          }

          word = buildGetSend(stack, word);

          while (stack.peek() == SingleQ) {
            stack.pop()
            word = new Quoted(word)
          }

          stack.push(word);
          word = null;
        }
        break;
      case ".":
        if (word) {
          switch (true) {
            case /^\d+\.$/.test(word):
            case /^:.+$/.test(word):
              word += c;
              return;
            case /^.+$/.test(word):
              stack.push(new Symbol(word));
              stack.push(Dot);
              word = null;
              return;
          }
        } else {
          word = c;
        }
        break;
      case '/':
        if (word) {
          if (stack.peek() != Slash) {
            stack.push(new Symbol(word));
            word = null;
            stack.push(Slash);
          } else {
            word += c;
          }
        } else {
          word = c;
        }
        break;
      case ';':
        comment = true;
        break;
      default:
        if (word)
          word += c;
        else
          word = c;
    }
  });

  if (word) {
    switch(true) {
      case number.test(word):
        word = parseInt(word);
        break;
      case keyword.test(word):
        word = new Keyword(word.substr(1));
        break;
      case /^.+$/.test(word):
        word = new Symbol(word);
        break;
    }

    while (stack.peek() == SingleQ) {
      stack.pop();
      word = new Quoted(word);
    }

    stack.push(word);
    word = null;
  }

  return stack;
}

var get  = new Symbol('get'),
    send = new Symbol('send');
function buildGetSend(stack, word) {
  var list, d;
  if(stack.peek() == Slash ||
     stack.peek() == Dot) {

    if (! word instanceof Symbol) {
      throw("Expected a Symbol got a " + word.constructor);
    }

       d = stack.pop();
    word = new Quoted(word);
    list = new List(word);
    while (stack.peek() instanceof Symbol) {
      word = stack.pop();
      word = new Quoted(word);
      list = list.push(word);
      if (stack.peek() == Dot)
        stack.pop();
      else
        break;
    }

    word = list.peek();
    list = list.pop();
    list = list.push(word.unquote());

    if(stack.peek() == LParen
              &&  d == Dot) {
      stack.push(send);
      var length = list.count();
      if (length == 2) {
        stack.push(list.head);
      } else {
        if (length < 2)
          throw("Is it your birthday?");
        list = list.push(get);
        stack.push(list.shift());
      }
      word = list.last;
    } else {
      list = list.push(get);
      word = list;
    }
  }
  return word;
}
//-async call structure
//-namespaces
function evl(exp, ns={}, bnd) {
  var q, args;
  switch (exp.constructor) {
    case Symbol: {
      // return bnd[exp];
      let value = null;
      exp = exp.toString()
      if (bnd) {
        value = bnd[exp];
        if (value)
          return value;
      }

      value = ns[exp];
      if (value)
        return value;

      if(ns.requires) {
        value = ns.requires.find(function(ns){
          return ns[exp];
        });
        if (value)
          return value;
      }

      // value = bubls.core[exp];
      value = bubblescript.core[exp];
      if(value)
        return value;

      return bubls[exp];
    }
    case List: {
      // loop {
      //   recur()
      // }

      let quack = evl(exp.first, ns, bnd);
      while (quack instanceof Symbol ||
             quack instanceof List) {
        let wack = evl(quack, ns, bnd);
        if (wack == undefined)
          throw(quack + " is wack");
        quack = wack;
      }

      if (quack.macro) {
        return evl(quack(exp.rest), ns, bnd);
      } else {
        // let k = function(a) { return evl(a, ns, bnd);}).toArray()),
        let k = function(a) { return evl(a, ns, bnd);}, //).toArray()),
            s = exp.rest.map(k);
        // let s = exp.rest.map(k);
        return quack(...s.toArray());
        // return quack(s);
      }
      // return quack()
      // return quack.call(bnd, exp.rest);

    //   if (quack instanceof Fn ||
    //       quack instanceof Macro ||
    //       quack instanceof Function) {
    //     return quack.call(bnd, exp.rest);
    //   // } else if (q instanceof Keyword) {
    //   //   return evl()
    // } else if (quack) {
    //   return evl(bnd,exp.second);
    // } else if (exp.third) {
    //   return evl(bnd,exp.third);
    // }

    // return st1.call(bnd, exp.rest)
    //
    //
    //   if (q instanceof Fn
    //       q instanceof Macro
    //       q instanceof Function) {
    //     return q.call(bnd, exp.rest);
    //   } else if (q) {
    //
    //   } else {
    //
    //   }
    //
    //   let q = evl(bnd, exp.first);
    //   while (q instanceof Symbol|List) {
    //     q = evl(bnd, q);
    //   }
    //
    //   let q = evl(bnd, exp.first);
    //   while (q instanceof in [Symbol, List]) {
    //   loop [q evl(bnd, exp.first)]
    //     (if q.)
    //     let q = evl(bnd, exp.first);
    //     recur(evl(bnd, exp.first))
    //   }
    //   if (q.call) {
    //
    //   }
    //   if (q instanceof Fn ||
    //       q instanceof Macro ||
    //       q instanceof Function) {
    //       return q.call(bnd, args.rest);
    //   }
    //
    //   if (q instanceof Symbol ||
    //       q instanceof List) {
    //     if (q==undefined) {
    //       throw("No such function or macro: " + exp.first);
    //     }
    //     args = exp.rest;
    //     return q.call(bnd, args);
    //   } else {
    //     if (exp.first instanceof List) {
    //       let q = evl(bnd, exp.first),
    //           exp = exp.pop();
    //       switch(q.constructor) {
    //         case Symbol:
    //         case Fn:
    //         case Macro:
    //         case List:
    //           return evl(bnd, exp.push(q));
    //       }
    //       if (q) {
    //         return evl(bnd, exp.first);
    //       } else {
    //         let exp = exp.pop();
    //         if (exp)
    //           return evl(bnd, exp.first);
    //         else
    //           return false;
    //       }
    //     }
    //   }
      break; }
    case Glider:
      // console.log(exp);
      // console.log(exp.map(function(a) {evl(bnd,a)}));
      return exp.map(function(a) {return evl(bnd,a)});
    case Fn:
    case Macro:
      return exp.body.each(function(exp){
        return evl(bnd,exp);
      });
    case Quoted:
      return exp.unquote();
    default:
      return exp;
  }
};

function invoke(bnd, fn, args) {
  var bnd = Object.create(bnd);

  // var q = map(glider, fn.args, args)
  // console.log(q.toString());

  var x,y;
  x = fn.args; y = args;
  while (x) {
    if(x.first == '&'){
      x = x.rest;
      bnd[x.first] = y
      x = null; y = null;
      break;
    }
    // console.log(x)
    bnd[x.first] = y.first;
    x = x.rest; y = y.rest;
  }


  //bnd = createBinding(bnd, args);

  return evl(bnd,fn);
}

function map(fn, list, ...lists) {
  return list.map(fn, ...lists);
}

function push(a, b) {
  return a.push(b);
}

function glider(...args) {
  var head = args.pop(), tail = args ;
  if(tail.length > 0)
    return new Glider(head, glider(...tail));
  return new Glider(head);
}

bubl.glider = glider;
bubl.bubbleParse = bubbleParse;
bubl.evl = evl
bubl.Fn = Fn;
bubl.Macro = Macro;


bubbleParse = bubl.bubbleParse;
evl = bubl.evl;
Fn = bubl.Fn;
Macro = bubl.Macro;


function bubbleSCRiPT(s) {
  return bubbleParse(s.trim()).map(function(exp){
    // return evl(bnd,exp);
    // return evl(bubblescript,exp);
    return evl(exp);
  }).pop();
}

// function bubbleSCRiPT(bnd, s=null) {
  // return bubbleParse(s.trim()).map(function(exp){
    // return evl(bnd,exp);
  // }).pop();
// }


// var bnd =
var bubblescript={
  window: window,
  document: document
}
var bnd = bubblescript;
bubblescript.bubblescript=bubblescript;
bubblescript.core = {

  def: function(args) {
    var a, b, ns=bnd, bnd=this;
    a = args.first;
    b = args.rest.first;
    ns[a.toString()] = evl(bnd, b);
  },

  send: function(args) {
    var target, msg, bnd=this;
    target = evl(bnd,args.first);
    msg = args.rest.map(function(a){return evl(bnd,a)});

    // if(a==undefined)
    //   throw(reciever + " didn't respond to " + msg.first);

    if (msg.rest) {
      return target[msg.first](...msg.rest.toArray());
    } else {
      return target[msg.first]();
    }
  },

  get: function(args) {
    var bnd=this
    return args.map(function(a){
              return evl(bnd,a);})
    .reduce(function(a,b) {
      if (a) {
        return a[b];
      } else {
        return b;
      }
    });
  },

  export: function(crunch) {
    var ca,nd,y,bnd;
    bnd=this;
    [ca,nd,y]=crunch
      .map(function(q){
        return evl(bnd,q);
      }).toArray();
    return ca[nd]=y;
  },

  fn: function(args) {
    var bnd = this;
    return new Fn(bnd, args.first, args.rest);
  },

  macro: function (args) {
    var bnd = this;
    return new Macro(bnd, args.first, args.rest)
  },

  jsfn: function(args) {
    var x, bnd = this
    x = args.push(new Symbol('fn'));
    var fn = evl(bnd, x);
    return function(...args) {
      var list = new List(args.pop());
      while (args.length>0) {
        list = list.push(args.pop());
      }

      return fn.call(bnd, list);
    }
  },

  let: function(hamburgers) {
    var icecream = hamburgers.first,
        pineapple = Object.create(this),
        splash, sunshine,
        elves=evl;

    while (icecream) {
      splash = icecream.first;
      sunshine = icecream.rest;
      pineapple[splash] = elves(pineapple, sunshine.first);
      icecream = sunshine.rest;
    }

    hamburgers.rest.each(function (xoxo){
      return elves(pineapple, xoxo);
    })
  },

  not: function(y) { return !y },
  and: function(a,b) { return a && b; },
   or: function(a,b) { return a || b; },

  if: function(rainbows) {
    var turbulance = rainbows.peek(),
        kango = rainbows.pop(),
        bnd = this,
        elves = evl;

    if(elves(bnd,turbulance)){
      return elves(bnd, kango.peek());
    } else {
      let bambo = kango.pop();
      if (bambo)
        return elves(bnd, bambo.peek());
      else
        return false;
    }
  },

  expandmacro: function (args) {
    var bnd = this,
        l = args.first,
        m = l.first;

    m = evl(bnd, m);
    return m.expand(bnd, l.rest);
  },

  ns: function(flinflan){
    var o=flinflan.peek();
    var namespace=evl(root, o);
    if(!namespace){
      // Init
      if(o instanceof Symbol) {
        namespace=Object.create(root);
        root[o]=namespace;
      } else {
        //}(one instanceof List) {
        let a=o.pop(),
            p=root,
            f;
        while(a){
          f=a.peek();
          if(f instanceof Quoted)
            f=f.unquote();
          p=p[f]||Object.create(root);
          p[f]=p;
          a=a.pop();
        }
        p[f]=namespace;
      }
    }

    // root={};
    // lookup namespace
    // set namespace
    // imports and requires
  },

  print: function(...vals) {
    var bnd = this;

    console.log('vals?', vals)
    vals.
      map(function(a){return evl(a,bnd)}).
      forEach(function(value){
        document.body.append(value)});
  },

  list: function(args) {
    var bnd = this;
    return args.map(function(arg){
      return evl(bnd, arg);
    })
  },
  "+": function(args){
    var bnd = this;
    args = args.map(function(x) {return evl(bnd, x);});
    console.log(args);
    return args.reduce(function(a, b){return a+b;});
  },
  "-": function(args){
    return args.reduce(function(a, b){return a-b;});
  },
  "*": function(args){
    return args.rest.reduce(function(a, b){return a*b;}, args.first);
  },
  "/": function(args){
    return args.reduce(function(a, b){return a/b;});
  },
  alert: function(msg) {
    alert(msg);
  },
  parse: function(args) {
    return bubbleParse(args.first);
  },
  evl: function(args) {
    return evl(this, args.first);
  }
  // set: function(key,value) {
  //   this[key] = value;
  // }
}


//bubbleSCRiPT("\
  //(def println\n\
    //(fn [a] (print a \"\\n\")))\n\
//\n\
  //(def blank [a & b]\n\
    //(log a)\n\
    //(log b))\n\
//\n\
//");

// bubbleSCRiPT("\
//   (def println\n\
//     (fn [a] (print a \"\\n\")))\n\
// ");

// (def vector
//   (fn [first & rest]
//    (reduce (fn [a b]
//      (new Vector a b))
//      rest
//      (new Vector first))))
//
// (def vector
//   (fn [first & rest]
//     (reduce conj rest
//       (new Vector first))))
//
// (def vector
//   (fn [first & rest]
//     (conj (new Vector first) & rest)))
//
// (def map ())

// (fn [frag] (send document :append "xyz"))

// (def println
//   (fn [a] (print a "<br>")))

// export { BubbleScript, List };


function async(fn, ...params) {
  setTimeout(fn,0,...params);
}

// Fecthes a script from the URL
// and passes it to the callback.
// Asyncronous, does not block.
function fetchScript(url, callback) {
  xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4) {
      if (this.status == 200) {
        callback(xhttp.responseText);
      } else {
        error(url + " returned " + this.status);
      }
    }
  }
  xhttp.open('GET', url);
}

// Fetches each script and invokes
// callback on each one in succession
function fetchScripts1(scripts, cbk) {
  var open =  0, // how many downloads are currently "open"
        counter = 0,
            fetchQ = [],
              wait = [],
                 flash  =  1;

  function getAtMe(order,callback) {
    return function (response) {
      if (fetchQ.length>0) {
        let script,order,callback;
        [script,order,callback] = fetchQ.shift();
        fetchScript(script, getAtMe(order,callback));
      } else {
        open-- ;
      }

      scriptReady(order,callback,response);
    }
  }

  function scriptReady(order,callback,response) {
    var cmp=getComplete(order);

    if(order==flash){
      if (callback(response.text,cmp))
        cmp();
    } else if (order>flash) {
      wait[order]=[callback,response,cmp];
    } else {
      throw "that is some weird wild stuff";
    }
  }

  function getComplete(order) {
    return function() {
      if (order!=flash)
        return;
      flash++;
      setTimeout(clearWait, 0);
    }
  }

  function clearWait () {
    var cb,r,cmp;
    if(wait[flash]) {
      [cb,r,cmp]=wait[flash];
      delete wait[flash];
      if (cb(r.text,cmp)) cmp();
    }
  }

  while(scripts) {
    let script = scripts.head;
    counter++;
    if(script.src=='') {
      // scriptReady(counter,callback,{text: script.innerHTML});
      // setTimeout(scriptReady,0,counter,callback, {text: script.innerHTML});
      async(scriptReady,counter,callback, {text: script.innerHTML});
    } else {
      if (open<3) {
        fetchScript(script.src, getAtMe(counter, callback));
        open++;
      } else {
        fetchQ.push([script,counter,callback]);
      }
    }
    scripts=scripts.rest;
  }

  return {};
}

// TODO: Please document
// To confirm: downloads each script in scripts
//  invoking callback with response and finally calling
//  fin when the final script returns. No order guarnteed.
function fetchScripts2(scripts, callback, fin) {
  var open = 0; // how many downloads are currently "open"

  function happyMeal(response) {
    if (scripts) {
      fetchScript(scripts.head, happyMeal);
      scripts=scripts.rest;
    } else
      open--;

    callback(response.text);

    // if (= open 0)
    if (open == 0)
      fin();
  }

  while(scripts && open<3) {
    fetchScript(scripts.head, happyMeal);
    open++;
    scripts=scripts.rest;
  }

  return {};
}


window.addEventListener('load', function () {
  frosty = document.querySelectorAll(
    "script[type='text/bubblescript']")
  var shiverMeTimbers =
    function(meTimbers) {
      meTimbers = [...meTimbers];
      if (meTimbers.length == 0)
        return 'blarney';

      var icepop = meTimbers.pop(),
          recur = this.prototype;
      if(icepop.src!='') {
        xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
          if (this.readyState == 4) {
            if (this.status == 200) {
              bubbleSCRiPT(bnd,xhttp.responseText);
            } else {
              console.log(ice.src + " returned " + this.status);
            }
            return recur(meTimbers);
          }
        }
        xhttp.open('GET', icepop.src);
      } else {
        // bubbleSCRiPT(bnd,icepop.innerText);
        console.log(icepop.innerText);
        bubbleSCRiPT(icepop.innerText);
        return recur(meTimbers);
      }
    }
  return shiverMeTimbers(frosty);
  // frosty.forEach(function(ice) {
  // })
});




bubl.bubbleSCRiPT = bubbleSCRiPT;
bubl.bubbleParse = bubbleParse;
bubl.bnd = bnd;

// bubl.w = function(s) { return bubbleSCRiPT(bnd, s) };
bubl.w = function(s) { return bubbleSCRiPT(s) };
bubl.m = function(s) { return bubbleParse(s); };

})();

var w = bubl.w;
var m = bubl.m;

/* bubblescript 🍭

(defmacro if [m & q]
  (new If m q))
*/

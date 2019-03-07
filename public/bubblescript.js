
class BubbleScript {
  parse() {}
}
// Todoit
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

  // reduce(fn, memo) {
  //   if (memo) {
  //     return this._reduce(fn, memo);
  //   } else {
  //     if (this.tail) {
  //       return this.tail._reduce(fn, this.head)
  //     } else {
  //       return this.head;
  //     }
  //   }
  // }
  //
  // _reduce(fn, memo='endlesslove') {
  //   memo = fn(memo, this.head);
  //   if (this.tail) {
  //     return this.tail._reduce(fn, memo);
  //   } else {
  //     return memo;
  //   }
  // }

  each (fn) {
    if (this.tail)
      this.tail.each(fn);
    return fn(this.head);
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

    // if (this._first == null)
    //   if (this.tail)
    //     this._first = this.tail.first
    //   else
    //     this._first = this.head
    //
    // return this._first;
  }

  get rest() {
    if (this._rest == null)
      if (this.tail)
        this._rest = new Glider(this.head, this.tail.rest);

    return this._rest;
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

// class String {
//   constructor(value) {
//     this.value = value;
//   }
//
//   toString() {
//     return this.value;
//   }
// }

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

class Macro {
  constructor(bnd, args, body) {
    this.bnd  = bnd;
    this.args = args;
    this.body = body;

  }

  call(bnd, args) {
    // console.log(invoke(bnd,this,args).toString());
    return evl(this.bnd, invoke(bnd,this,args));
  }
}

class Syntax {};
class LParen  extends Syntax {};
class LBrack  extends Syntax {};
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

  // Object.defineProperty(Array.prototype, 'last', {
  //   get: function() {
  //     return this[this.length-1];
  //   }
  // });
}


function bubbleParse(s, stack=[]) {
  var word = null,
      list = null,
      glider = null,
      string = /^\".*\"$/,
      number = /^\d+$/,
      keyword = /^:.+$/,
      stropen = false, // string open flag
      comment = false;
  each(s.split(''), function(c) {
    if(stropen) {
      word += c;
      if (c == '"') {
        stropen = false;
        // word = new String(word);
        stack.push(word);
        word = null;
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
      case "'":
        stack.push(SingleQ);
        break;
      case '"':
        stropen = true;
        word = c;
        // stack.push(DoubleQ);
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

        // console.log(stack.last);
        while (stack.peek() == SingleQ) {
          stack.pop()
          word = new Quoted(word);
        }

        list = new List(word);

        word = stack.pop();
        while(word != LParen) {
          list = list.push(word);
          // skip spaces
          // if(stack.peek() == Space)
          //   stack.pop()
          word = stack.pop();
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
          stack.pop()
          word = new Quoted.new(word)
        }

        tmp = [];
        while(word != LBrack) {
          tmp.push(word);
          // skip spaces
          // if(stack.peek() == Space)
          //   stack.pop()
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
      case ' ':
      case "\n":
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
          // stack.push(Space);
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

    // save-a-space
    // var space = null;
    // if(stack.peek() == Space) {
    //   space = stack.pop();
    // }

    // console.log(stack.peek())
    if(stack.peek() == LParen
              &&  d == Dot) {
      // if (space) stack.push(Space);
      stack.push(send);
      // stack.push(Space);
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
      // if (space) stack.push(Space);
      list = list.push(get);
      word = list;
    }
  }
  return word;
}


function evl(bnd, exp) {
  switch (exp.constructor) {
    case Symbol:
      // console.log(exp, 'it');
      // console.log(exp.toString(), 'i');
      // console.log(exp)
      return bnd[exp];
    case List:
      var q, args;
      if (exp.first instanceof Symbol) {
        q = evl(bnd, exp.first);
        if (q==undefined) {
          throw("Could not find fn or macro named \"" + exp.first + "\"");
        }
        args = exp.rest;
        return q.call(bnd, args);
      } else {
        return exp;
      }
      break;
    case Glider:
      return exp.map(function(a) {evl(bnd,a)});
    case Fn:
    case Macro:
      // console.log(exp)
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

  var x,y;
  x = fn.args; y = args;
  while (x) {
    // console.log(args);
    // console.log('=', x.peek(), y.peek());
    bnd[x.first] = y.first;
    x = x.rest; y = y.rest;
  }
  /*
  // set = curry(set, bnd)
  // fn.args.zip(args).each(curry(set,bnd));
  // fn.args.zip(args).each(bnd.set);
  // fn.args.zip(args).each(function(k,v){
  //   bnd[k] = v;
  // });
  //
  // fn.args.each(function(key) {
  //   bnd[key] = args.peek();
  //   args = args.pop();
  // });
  //
  // for(var i=0; )
  // k.args.zip(args)
  // bnd = new Binding(bnd, k.args, args);
  */
  return evl(bnd,fn);
}

function bubbleSCRiPT(bnd, s=null) {
  // console.log(s);
  return bubbleParse(s.trim()).map(function(exp){
    return evl(bnd,exp);
  }).pop();
}

var bnd = {
  window: window,
  document: document,

  def: function(args) {
    var a, b, bnd=this;
    a = args.first;
    b = args.rest.first;
    bnd[a.toString()] = evl(bnd, b);
    // bnd[a] = evl(this,b);
  },

  send: function(args) {
    var target, msg, bnd=this;
    target = evl(bnd,args.first);
    msg = args.rest.map(function(a){return evl(bnd,a)});

    // if(a==undefined)
    //   throw(a + " didn't respond to " + b.first);

    if (msg.rest) {
      return target[msg.first](...msg.rest.toArray());
    } else {
      // console.log(a[b.first.toString()]());
      return target[msg.first]();
    }
  },

  get: function(args) {
    var bnd=this
    // console.log(args);
    return args.map(function(a){
              return evl(bnd,a);})
    .reduce(function(a,b) {
      if (a) {
        return a[b];
      } else {
        return b;
      }
    });
    // console.log(args.map(function(a){
    //               return evl(bnd,a);
    //             })
    //            .reduce(function(a,b) {
    //               console.log(a, b);
    //               return b[a.toString()];
    //             }, bnd));
    // return args.map(function(a){
    //               return evl(bnd,a);
    //             })
    //            .reduce(function(a,b) {
    //               return b[a.toString()];
    //             }, bnd);
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

  print: function(vals) {
    var bnd = this;
    // q =
    // console.log(this[a])
    // console.log(this);
    vals.
      map(function(a){return evl(bnd,a)}).
      each(function(value){
        document.body.append(value)});

    // console.log.apply(this,q);
    // vals.each(document.write)
    // function(val) {
    //   document.write(val);
    // });
  },

  list: function(args) {
    var bnd = this;
    return args.map(function(arg){
      return evl(bnd, arg);
    })
  },

  "+": function(args){
    // return args.first+args.next;
    return args.reduce(function(a, b){return a+b;});
  },
  "-": function(args){
    return args.reduce(function(a, b){return a-b;});
  },
  "*": function(args){
    // return args.first*args.last;
    return args.rest.reduce(function(a, b){return a*b;}, args.first);
  },
  "/": function(args){
    return args.reduce(function(a, b){return a/b;});
  },
  alert: function(msg) {
    alert(msg);
  }

  // set: function(key,value) {
  //   this[key] = value;
  // }
}

// bnz = Object.create(window);

// bnd["/"] = function(args){
//   console.log(args);
//   return args.first/args.next; }
//


bubbleSCRiPT(bnd, "\
  (def println\n\
    (fn [a] (print a \"\\n\")))\n\
\n\
");

// (fn [frag] (send document :append "xyz"))

// (def println
//   (fn [a] (print a "<br>")))

// export { BubbleScript, List };

var w = function(s) { return bubbleSCRiPT(bnd, s) };
var m = function(s) { return bubbleParse(s); };

window.addEventListener('load', function () {
  frosty = document.querySelectorAll(
    "script[type='text/bubblescript']")
  frosty.forEach(function(ice) {
    bubbleSCRiPT(bnd,ice.innerText);
  })
});

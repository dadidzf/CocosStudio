# -*- coding: utf-8 -*-

import pymongo
import sys
import traceback    

MONGODB_CONFIG = {
    'host': '127.0.0.1',
    'port': 27017,
    'db_name': 'herochess',
    'username': None,
    'password': None
}

class Singleton(object):
    # 单例模式写法,参考：http://ghostfromheaven.iteye.com/blog/1562618
    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, '_instance'):
            orig = super(Singleton, cls)
            cls._instance = orig.__new__(cls, *args, **kwargs)
        return cls._instance

class MongoConn(Singleton):    
    def __init__(self):
        # connect db
        try:
            self.conn = pymongo.MongoClient(MONGODB_CONFIG['host'], MONGODB_CONFIG['port'])
            self.db = self.conn[MONGODB_CONFIG['db_name']]  # connect db
            self.username=MONGODB_CONFIG['username']
            self.password=MONGODB_CONFIG['password']  
            if self.username and self.password:
                self.connected = self.db.authenticate(self.username, self.password)
            else:
                self.connected = True
        except Exception:
            print traceback.format_exc()
            print 'Connect Statics Database Fail.'
            sys.exit(1)  

    def check_connected(self):
        #检查是否连接成功
        if not self.connected:
            raise NameError, 'stat:connected Error' 

    def save(self, table, value):
        # 一次操作一条记录，根据‘_id’是否存在，决定插入或更新记录
        try:
            self.check_connected()
            self.db[table].save(value)
        except Exception:
            print traceback.format_exc()

    def insert(self, table, value):
        # 可以使用insert直接一次性向mongoDB插入整个列表，也可以插入单条记录，但是'_id'重复会报错
        try:
            self.check_connected()
            self.db[table].insert(value, continue_on_error=True)
        except Exception:
            print traceback.format_exc()

    def update(self, table, conditions, value, s_upsert=False, s_multi=False):
        try:
            self.check_connected()
            self.db[table].update(conditions, value, upsert=s_upsert, multi=s_multi)
        except Exception:
            print traceback.format_exc()

    def upsert_mary(self, table, datas):
        #批量更新插入，根据‘_id’更新或插入多条记录。
        #把'_id'值不存在的记录，插入数据库。'_id'值存在，则更新记录。
        #如果更新的字段在mongo中不存在，则直接新增一个字段
        try:
            self.check_connected()
            bulk = self.db[table].initialize_ordered_bulk_op()
            for data in datas:
                _id=data['_id']
                bulk.find({'_id': _id}).upsert().update({'$set': data})
            bulk.execute()
        except Exception:
            print traceback.format_exc()

    def upsert_one(self, table, data):
        #更新插入，根据‘_id’更新一条记录，如果‘_id’的值不存在，则插入一条记录
        try:
            self.check_connected()
            query = {'_id': data.get('_id','')}
            if not self.db[table].find_one(query):
                self.db[table].insert(data)
            else:
                data.pop('_id') #删除'_id'键
                self.db[table].update(query, {'$set': data})
        except Exception:
            print traceback.format_exc()

    def find_one(self, table, value):
        #根据条件进行查询，返回一条记录
        try:
            self.check_connected()
            return self.db[table].find_one(value)
        except Exception:
            print traceback.format_exc()

    def find(self, table, value):
        #根据条件进行查询，返回所有记录
        try:
            self.check_connected()
            return self.db[table].find(value)
        except Exception:
            print traceback.format_exc()

    def select_colum(self, table, value, colum):
        #查询指定列的所有值
        try:
            self.check_connected()
            return self.db[table].find(value, {colum:1})
        except Exception:
            print traceback.format_exc()

    def record_success_trade(self, tradeInfo):
        self.insert('trade', tradeInfo)

    def update_golds_for_fee(self, openid, fee):
        incGolds = 200
        self.update('account',{'openid':openid},{'$inc':{'golds':incGolds}}, False, False)


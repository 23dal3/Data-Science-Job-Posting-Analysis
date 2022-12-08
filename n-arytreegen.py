import pandas as pd
import json
""" A script that reads in the coefficient matrix of the R model: multinom(transformed.ownership ~ 
Founded.cat + Revenue + Size + Sector.new, data = glassdoor), and converts it into a n-ary tree of json format """

def leafCreator(name, category):
    """ Creates the leaves of the tree if a category """
    if int(category[name]) < 0:
        # if the leaves are negative then we round up to 0
        modified_name= name + " [this category tends towards 0]"
        return {"name": modified_name, "value": 0}
    else:
        return {"name": name, "value": category[name]}

class TreeNode(dict):
    def __init__(self, name, children=None):
        super().__init__()
        self.__dict__ = self
        self.name = name
        self.children = list(children) if children is not None else []

    @staticmethod
    def from_dict(dict_):
        """ Recursively (re)construct TreeNode-based tree from dictionary. """
        node = TreeNode(dict_['name'], dict_['children'])
        #node.children = [TreeNode.from_dict(child) for child in node.children]
        node.children = list(map(TreeNode.from_dict, node.children))
        return node

if __name__ == '__main__':
    # reads in the dataframe
    df = pd.read_csv('coeffs.csv')
    # breaks df into dictionaries depending on category
    private, public= df.to_dict(orient='records')
    # Odds root node
    odds = TreeNode('Log(Odds)')
    # Private Public child nodes
    Private = TreeNode('Private')
    odds.children.append(Private)
    Public = TreeNode('Public')
    odds.children.append(Public)
    # iteration for public-sub tree: Sector - Revenue - Size - Founded
    for key in public.keys():
        if "Sector" in key:
            keynode = TreeNode(key)
            Public.children.append(keynode)
            for key1 in public.keys():
                if "Revenue" in key1:
                    keynode1 = TreeNode(key1)
                    keynode.children.append(keynode1)
                    for key2 in public.keys():
                        if "Size" in key2:
                            keynode2 = TreeNode(key2)
                            keynode1.children.append(keynode2)
                            for key3 in public.keys():
                                if "Founded" in key3:
                                    keynode3 = TreeNode(key3)
                                    keynode2.children.append(keynode3)
                                    keynode3.children.append(leafCreator(key3, public))
                                    keynode3.children.append(leafCreator(key2, public))
                                    keynode3.children.append(leafCreator(key1, public))
                                    keynode3.children.append(leafCreator(key, public))
    # iteration for private-sub tree: Sector - Revenue - Size - Founded
    for key in private.keys():
        if "Sector" in key:
            keynode = TreeNode(key)
            Private.children.append(keynode)
            for key1 in private.keys():
                if "Revenue" in key1:
                    keynode1 = TreeNode(key1)
                    keynode.children.append(keynode1)
                    for key2 in private.keys():
                        if "Size" in key2:
                            keynode2 = TreeNode(key2)
                            keynode1.children.append(keynode2)
                            for key3 in private.keys():
                                if "Founded" in key3:
                                    keynode3 = TreeNode(key3)
                                    keynode2.children.append(keynode3)
                                    keynode3.children.append(leafCreator(key3, private))
                                    keynode3.children.append(leafCreator(key2, private))
                                    keynode3.children.append(leafCreator(key1, private))
                                    keynode3.children.append(leafCreator(key, private))
    # json casting of tree
    json_str = json.dumps(odds, indent=2)
    print(json_str)
    with open("coeffs_treegen.json", "w") as outfile:
        outfile.write(json_str)
    # print()
    # pyobj = TreeNode.from_dict(json.loads(json_str))  # reconstitute
    # print('pyobj class: {}'.format(pyobj.__class__.__name__))  # -> TreeNode
    # print(json.dumps(pyobj, indent=2))